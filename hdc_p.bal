import ballerinax/kafka;
import ballerina/graphql;
import ballerina/docker;
//docker exposer
@docker:Expose {}
listener graphql:Listener hdcListener = 
new(9060);
//kafka config
kafka:ProducerConfiguration producerConfiguration =
 {
    bootstrapServers: "localhost:9094",
    clientId: "HODProducer",
    acks: "all",
    retryCount: 3
};

//kafka implemetation 
kafka:Producer kafkaProducer = checkpanic 
new (producerConfiguration);
//GraphQL API
@docker:Config 
{
    name: "hdc",
    tag: "v1.0"
}
service graphql:Service /graphql on hdcListener 
{

    //approve proposal
    resource function get evaluateProposal
    (string studentNumber, string approved) 
    returns string {

        string hdcEvaluation = ({studentNumber, approved}).toString
        ();

        checkpanic kafkaProducer->sendProducerRecord
        ({
                                    topic: "hdcEvaluation",
                                    value: hdcEvaluation.toBytes() });

        checkpanic kafkaProducer->flushRecords
        ();
        return "Proposal Evaluated";
    }
}
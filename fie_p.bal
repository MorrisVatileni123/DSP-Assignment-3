import ballerinax/kafka;
import ballerina/graphql;
import ballerina/docker;
//docker exposer
@docker:Expose 
{}
listener graphql:Listener fieListener = 
new(9050);
//docker config
kafka:ProducerConfiguration producerConfiguration = 
{
    bootstrapServers: "localhost:9094",
    clientId: "HODProducer",
    acks: "all",
    retryCount: 3
};
docker implementation
kafka:Producer kafkaProducer = checkpanic 
new (producerConfiguration);
//GraphQL APIg
@docker:Config 
{
    name: "fie",
    tag: "v1.0"
//fie listener
service graphql:Service /graphql on fieListener 
{

    //sanction proposal
    resource function get proposalSanction(string studentNumber, string approved)
     returns string {
        
        string fieAssign = ({studentNumber, approved}).toString();

        checkpanic kafkaProducer->sendProducerRecord(
            {
                                    topic: "proposalSanction",
                                    value: fieAssign.toBytes() });

        checkpanic kafkaProducer->flushRecords();
        return "Sanctioned Proposal";
    }
}


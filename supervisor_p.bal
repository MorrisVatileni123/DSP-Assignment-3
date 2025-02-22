import ballerinax/kafka;
import ballerina/graphql;
import ballerina/docker;

//docker exposure
@docker:Expose {}
listener graphql:Listener supervisorListener = 
new(9080);

kafka:ProducerConfiguration producerConfiguration =
 {
    bootstrapServers: "localhost:9094",
    clientId: "supervisorProducer",
    acks: "all",
    retryCount: 3
};


kafka:Producer kafkaProducer = checkpanic new (producerConfiguration);

//GraphQL API
@docker:Config 
{
    name: "supervisor",
    tag: "v1.0"
}
service graphql:Service /graphql on supervisorListener
 {
    //select applicant
    resource function get selectApplicant(int studentNumber, int supervisorID) 
    returns string {
        
        string interested = ({studentNumber, supervisorID}).toString();
        checkpanic kafkaProducer->sendProducerRecord({
                                    topic: "supervisorApplicantSelection",
                                    value: interested.toBytes() });

        checkpanic kafkaProducer->flushRecords();
        return "selected applicant";
    }

    
    resource function get reviewProposal(int studentNumber, string proposalApproved) 
    returns string {
        string review = ({studentNumber, proposalApproved}).toString();
        checkpanic kafkaProducer->sendProducerRecord({
                                    topic: "supervisorProposalReview",
                                    value: review.toBytes() });

        checkpanic kafkaProducer->flushRecords();
        return "Proposal Reviewed";
    }

    

}

import ballerinax/kafka;
import ballerina/graphql;
import ballerina/docker;
//docker exposure
@docker:Expose {}
listener graphql:Listener hodListener = 
new(9070);

kafka:ProducerConfiguration producerConfiguration = 
{
    bootstrapServers: "localhost:9094",
    clientId: "HODProducer",
    acks: "all",
    retryCount: 3
};

kafka:Producer kafkaProducer = checkpanic 
new (producerConfiguration);
//GraphQL API
@docker:Config {
    name: "hod",
    tag: "v1.0"
}
service graphql:Service /graphql on hodListener 
{

    //approve supervisor selection based their exprerience
    resource function get approveSupervisorSelection(int studentNumber, string approved) 
    returns string {
        
        string hodRes = ({studentNumber, approved}).toString();
        checkpanic kafkaProducer->sendProducerRecord({
                                    topic: "hodSupervisorSelectionApproval",
                                    value: hodRes.toBytes() });

        checkpanic kafkaProducer->flushRecords();
        return "Supervisor Approved";
    }

    //assign FIE to proposal
    resource function get assignFIE(int studentNumber, int fieID) 
    returns string {
        
        string fieAssign = ({studentNumber, fieID}).toString();
        checkpanic kafkaProducer->sendProducerRecord({
                                    topic: "hodAssignFie",
                                    value: fieAssign.toBytes() });

        checkpanic kafkaProducer->flushRecords();
        return "Assigned FIE";
    }

    

    resource function get finalSubmission(int studentNumber) 
    returns string {
        
        //change student status to final submission
        checkpanic kafkaProducer->sendProducerRecord({
                                    topic: "hodFinalAdmission",
                                    value: studentNumber.toString().toBytes() });

        checkpanic kafkaProducer->flushRecords();
        return "Final Admission complete";
    }
}


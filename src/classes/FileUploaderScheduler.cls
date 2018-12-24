/*********************************************************************************
Class Name      : FileUploaderScheduler
Description     : Scheduler class for uploading documents to Team Drive
Created By      : FEBRIAN NEDSENDA RIZKY
Created Date    : November 15, 2018
Modification Log:
---------------------------------------------------------------------------------- 
Developer                   Date                   Description
-----------------------------------------------------------------------------------            
Febrian Nedsenda Rizky		November 15, 2018      Initial Version
*********************************************************************************/
global class FileUploaderScheduler implements Schedulable{
    global void execute(SchedulableContext sc) {
        map<id,Document_Log__c> mapOfDocumentLog = new map<id,Document_Log__c>();
        Datetime dt = system.now()-1;
        //query document log to get all objects related to document
        for( Document_Log__c dl : 
            [Select Document__r.id, Document__r.MAP_ID__c, Document__r.Document_Category__c, 
                 Document__c, Document__r.Name, Name, Id,
                 Cycle_Lookup__r.Program_Coverage__r.Program__r.CaseNumber,
                 Cycle_Lookup__r.Brand_1__c ,
                 Cycle_Lookup__r.Brand_1_Type__c,
                 Cycle_Lookup__r.Brand_1_Free_Strength_1__c,
                 Cycle_Lookup__r.Brand_1_Free_Strength_2__c,
                 Cycle_Lookup__r.Brand_1_Free_Strength_3__c,
                 Cycle_Lookup__r.Brand_2__c ,
                 Cycle_Lookup__r.Brand_2_Type__c,
                 Cycle_Lookup__r.Brand_2_Free_Strength_1__c,
                 Cycle_Lookup__r.Brand_2_Free_Strength_2__c,
                 Cycle_Lookup__r.Brand_2_Free_Strength_3__c,
             	 Cycle_Lookup__r.Name,
             	 Cycle_Lookup__r.Id,
            	 Cycle_Lookup__r.Program_Coverage__r.Scheme__r.MAP_Reference__c,
             	 Cycle_Lookup__r.Program_Coverage__r.Scheme__r.Units__c,
                 Program__r.casenumber 
                 From Document_Log__c
                 WHERE Document__r.Document_Category__c INCLUDES ('FOC Application Form') 
                 AND ((Cycle_Lookup__r.Brand_1__c != NULL AND Cycle_Lookup__r.Brand_1_Type__c ='Free' AND Cycle_Lookup__r.Brand_1_Free_Strength_1__c !=NULL) 
                      OR (Cycle_Lookup__r.Brand_2__c != NULL AND Cycle_Lookup__r.Brand_2_Type__c ='Free' AND Cycle_Lookup__r.Brand_2_Free_Strength_1__c !=NULL))
                 AND Cycle_Lookup__r.Program_Coverage__r.Program__r.Engagement_Program__r.Name ='PSP TW' 
             	 AND CreatedDate > :dt AND Document__r.Owner.Profile.Name ='Patient Connect Care Coordinator'
            ]  ){
            mapOfDocumentLog.put(dl.Document__c, dl );
        }
        //run batch class
        FileUploaderBatch bat = new FileUploaderBatch( mapOfDocumentLog ); 
        //set the size to 10
        Database.executebatch(bat,1);
    }
}
/*********************************************************************************
Class Name      : FileUploaderBatch
Description     : Batch class for uploading documents to team drive
Created By      : FEBRIAN NEDSENDA RIZKY
Created Date    : November 15, 2018
Modification Log:
---------------------------------------------------------------------------------- 
Developer                   Date                   Description
-----------------------------------------------------------------------------------            
Febrian Nedsenda Rizky		November 15, 2018      Initial Version
*********************************************************************************/
global class FileUploaderBatch implements Database.Batchable<sObject>,Database.AllowsCallouts{
    public List<FileUploaderHandler.FileWrapper> listOfFileWrapper;
    public map<id,Document_Log__c> mapOfDocumentLog;
    public List<GDrive_File_Upload_Error__c> listOfErrors;
    /*********************************************************************************
    CONSTRUCTOR
    Description    : Constructor to fetch map from scheduler
    Input Params   : Map <Id of document, document log>
    *********************************************************************************/
    public PC_Roche_FileUploaderBatch ( map<id,Document_Log__c> aMapOfDocLog ){
        mapOfDocumentLog = aMapOfDocLog;
    }
    //get all attachment that match with map key
    global Database.QueryLocator start(Database.BatchableContext BC){
        Set<Id> setDocumentIds = mapOfDocumentLog.keyset();
        return Database.getQueryLocator('Select id, Body, BodyLength, ContentType, Name, ParentId FROM Attachment WHERE ParentId IN: setDocumentIds');
    }
    global void execute(Database.BatchableContext BC, List<Attachment> scope){
        system.debug(mapOfDocumentLog);
        listOfFileWrapper = new List<FileUploaderHandler.FileWrapper>();
        
		for(Attachment att : scope){
            system.debug('ParentID::: ' + mapOfDocumentLog.containskey(att.ParentId));
            if(mapOfDocumentLog.containskey(att.ParentId)){
                //get document log from attachment parent id (document id)
                Document_Log__c dl = mapOfDocumentLog.get(att.ParentId);
                //prepare filewrapper records
                PC_Roche_FileUploaderHandler.FileWrapper fw = new PC_Roche_FileUploaderHandler.FileWrapper(data to pass);
                if(fw.brandName1 !=null && fw.brandName1 !='' && fw.brandType1 =='Free' && fw.brandName2 !=null && fw.brandName2 !='' && fw.brandType2 =='Free')
                    listOfFileWrapper.add(fw);
                else if(fw.brandName1 !=null && fw.brandName1 !='' && fw.brandType1 =='Free')
                    listOfFileWrapper.add(fw);
                else if(fw.brandName2 !=null && fw.brandName2 !='' && fw.brandType2 =='Free')
                    listOfFileWrapper.add(fw);
            }
        }
        system.debug('listOfFileWrapper::::' +listOfFileWrapper.size() + listOfFileWrapper);
        if(listOfFileWrapper.size() > 0){
            FileUploaderHandler.uploadFile(listOfFileWrapper);
        }
    }
    global void finish(Database.BatchableContext BC){
        
    }
}
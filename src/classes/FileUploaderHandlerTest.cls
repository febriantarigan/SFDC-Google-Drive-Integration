@isTest
public class FileUploaderHandlerTest {
    @testSetup 
    static void setup() {
        /*Profile p = [SELECT Id FROM Profile WHERE Name='Patient Connect Care Coordinator'];
        User user = new User(Alias = 'standt1',Affiliate__c='TW',Country='Taiwan',Email='demo1@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='fileuploadertest@roche.com');
        insert user;*/
        User user = [SELECT Id FROM User WHERE Profile.Name='Patient Connect Care Coordinator' AND Affiliate__c='TW' LIMIT 1];
        Id accPatientRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
        Account acc = new Account(Name='Test Account', RecordTypeId =accPatientRT, Affiliate__c='TW');
        insert acc;
        Engagement_Program__c engProg = new Engagement_Program__c(Name='PSP TW', Program_Code__c='TWEP1',Affiliate__c='TW',Active__c=true);
        insert engProg;
        Id caseProgramRT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Program').getRecordTypeId();
        Scheme__c scheme = new Scheme__c(Name='TW Perjeta Scheme',MAP_Reference__c='MAP-123',Affiliate__c='TW', Units__c='mg');
        insert scheme;
        Case cs = new Case(Account = acc, RecordTypeId = caseProgramRT,Status='In Treatment', Engagement_Program__c=engProg.id, Active_Scheme__c=scheme.id);
        insert cs;
        //brand 2 free
        Program_Coverage__c progCoverage = new Program_Coverage__c(Scheme__c=scheme.id,Coverage_Type__c='FOC',Program__c=cs.id);
        insert progCoverage;
        Cycle__c cycle = new Cycle__c(Brand_1__c='Kadcyla',Brand_1_Type__c='Paid', Brand_2__c='Kadcyla',Brand_2_Type__c='Free',Program_Coverage__c=progCoverage.id,Brand_2_Free_Strength_1__c=100,Brand_2_Free_Strength_2__c=120,Brand_2_Free_Strength_3__c=140);
        insert cycle;
        Id docManualUploadRT = Schema.SObjectType.Document__c.getRecordTypeInfosByName().get('Manual Upload').getRecordTypeId();
        Document__c document = new Document__c(OwnerId=user.Id, Scheme__c=scheme.id,RecordTypeId=docManualUploadRT,Affiliate__c='TW',Document_Category__c='FOC Application Form');
        insert document;
        Document_Log__c documentLog = new Document_Log__c(Document__c=document.id, Cycle_Lookup__c=cycle.id, Account__c=acc.id, Coverage__c=progCoverage.id, Program__c=cs.id);
        insert documentLog;
        //brand 1 and brand 2 free
        Cycle__c cycle2 = new Cycle__c(Brand_1__c='Kadcyla',Brand_1_Type__c='Free', Brand_2__c='Kadcyla',Brand_2_Type__c='Free',Program_Coverage__c=progCoverage.id, Brand_1_Free_Strength_1__c=100,Brand_1_Free_Strength_2__c=120,Brand_1_Free_Strength_3__c=140, Brand_2_Free_Strength_1__c=100,Brand_2_Free_Strength_2__c=120,Brand_2_Free_Strength_3__c=140);
        insert cycle2;
        Document__c document2 = new Document__c(OwnerId=user.Id, Scheme__c=scheme.id,RecordTypeId=docManualUploadRT,Affiliate__c='TW',Document_Category__c='FOC Application Form');
        insert document2;
        Document_Log__c documentLog2 = new Document_Log__c(Document__c=document2.id, Cycle_Lookup__c=cycle2.id, Account__c=acc.id, Coverage__c=progCoverage.id, Program__c=cs.id);
        insert documentLog2;
        //brand 1 free
        Cycle__c cycle3 = new Cycle__c(Brand_1__c='Kadcyla',Brand_1_Type__c='Free',Program_Coverage__c=progCoverage.id, Brand_1_Free_Strength_1__c=100,Brand_1_Free_Strength_2__c=120,Brand_1_Free_Strength_3__c=140);
        insert cycle3;
        Document__c document3 = new Document__c(OwnerId=user.Id, Scheme__c=scheme.id,RecordTypeId=docManualUploadRT,Affiliate__c='TW',Document_Category__c='FOC Application Form');
        insert document3;
        Document_Log__c documentLog3 = new Document_Log__c(Document__c=document3.id, Cycle_Lookup__c=cycle3.id, Account__c=acc.id, Coverage__c=progCoverage.id, Program__c=cs.id);
        insert documentLog3;
        
        Attachment att = new Attachment();
		Blob bodyBlob =  Blob.valueOf('Test File Upload');
		att.Body = bodyBlob;
        att.Name = 'testMe';
        att.ContentType = 'text/plain';
        att.parentId=document.id;
        insert att;
        
        Attachment att2 = new Attachment();
		bodyBlob =  Blob.valueOf('Test File Upload2');
		att2.Body = bodyBlob;
        att2.Name = 'testMe';
        att2.ContentType = 'text/plain';
        att2.parentId=document2.id;
        insert att2;
        
        Attachment att3 = new Attachment();
		bodyBlob =  Blob.valueOf('Test File Upload2');
		att3.Body = bodyBlob;
        att3.Name = 'testMe';
        att3.ContentType = 'text/plain';
        att3.parentId=document3.id;
        insert att3;
        
    }
    
    @isTest static List<FileUploaderHandler.FileWrapper> getAllRelatedRecords() {
        map<id,Document_Log__c> mapOfDocumentLog = new map<id,Document_Log__c>();
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
            ]  ){
                //AND CreatedDate > :dt
                mapOfDocumentLog.put(dl.Document__c, dl );
            }
        List<FileUploaderHandler.FileWrapper> listOfFileWrapper = new List<FileUploaderHandler.FileWrapper>();
        Set<Id> setDocumentIds = mapOfDocumentLog.keyset();
		for(Attachment att : [Select id, Body, BodyLength, ContentType, Name, ParentId FROM Attachment WHERE ParentId IN: setDocumentIds]){
            if(mapOfDocumentLog.containskey(att.ParentId)){
                //get document log from attachment parent id (document id)
                Document_Log__c dl = mapOfDocumentLog.get(att.ParentId);
                //prepare filewrapper records
                FileUploaderHandler.FileWrapper fw = new FileUploaderHandler.FileWrapper(dl.Document__r.Name, att.Body, att.ContentType, dl.Cycle_Lookup__r.Program_Coverage__r.Program__r.CaseNumber, dl.Cycle_Lookup__r.Name, dl.Cycle_Lookup__r.Id, dl.Cycle_Lookup__r.Brand_1__c, dl.Cycle_Lookup__r.Brand_1_Type__c, dl.Cycle_Lookup__r.Brand_1_Free_Strength_1__c, dl.Cycle_Lookup__r.Brand_1_Free_Strength_2__c, dl.Cycle_Lookup__r.Brand_1_Free_Strength_3__c, dl.Cycle_Lookup__r.Brand_2__c, dl.Cycle_Lookup__r.Brand_2_Type__c, dl.Cycle_Lookup__r.Brand_2_Free_Strength_1__c, dl.Cycle_Lookup__r.Brand_2_Free_Strength_2__c, dl.Cycle_Lookup__r.Brand_2_Free_Strength_3__c, dl.Cycle_Lookup__r.Program_Coverage__r.Scheme__r.Units__c, dl.Cycle_Lookup__r.Program_Coverage__r.Scheme__r.MAP_Reference__c);
                if(fw.brandName1 !=null && fw.brandName1 !='' && fw.brandType1 =='Free' && fw.brandName2 !=null && fw.brandName2 !='' && fw.brandType2 =='Free')
                    listOfFileWrapper.add(fw);
                else if(fw.brandName1 !=null && fw.brandName1 !='' && fw.brandType1 =='Free')
                    listOfFileWrapper.add(fw);
                else if(fw.brandName2 !=null && fw.brandName2 !='' && fw.brandType2 =='Free')
                    listOfFileWrapper.add(fw);
            }
        }
        if(listOfFileWrapper.size() > 0)
        	return listOfFileWrapper;
        return listOfFileWrapper;
    } 
    @isTest public static void AllStrengthNotNull(){
                map<id,Document_Log__c> mapOfDocumentLog = new map<id,Document_Log__c>();
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
             	 AND Document__r.Owner.Profile.Name = 'Patient Connect Care Coordinator'
            ]  ){
                //AND CreatedDate > :dt
                mapOfDocumentLog.put(dl.Document__c, dl );
            }
      //  mapOfDocumentLog = new map<id,Document_Log__c>();
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new FileUploaderHandlerMock());
       	 	//HttpResponse res = FileUploaderHandler.testResponse();
       	 	FileUploaderBatch FUB = new FileUploaderBatch(mapOfDocumentLog);
        	DataBase.executeBatch(FUB,10);
        test.stopTest(); 
    } 
    @isTest public static void Strength1And2NotNull(){
        List<Cycle__c> listCycle = new List<Cycle__c>();
        for(Cycle__c cyc : [SELECT Id, Brand_1_Free_Strength_3__c, Brand_2_Free_Strength_3__c FROM Cycle__c]){
            cyc.Brand_1_Free_Strength_3__c =null;
            cyc.Brand_2_Free_Strength_3__c =null;
            listCycle.add(cyc);
        }
        update listCycle;
        map<id,Document_Log__c> mapOfDocumentLog = new map<id,Document_Log__c>();
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
             	 AND Document__r.Owner.Profile.Name = 'Patient Connect Care Coordinator'
            ]  ){
                //AND CreatedDate > :dt
                mapOfDocumentLog.put(dl.Document__c, dl );
            }
      //  mapOfDocumentLog = new map<id,Document_Log__c>();
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new FileUploaderHandlerMock());
       	 	//HttpResponse res = FileUploaderHandler.testResponse();
       	 	FileUploaderBatch FUB = new FileUploaderBatch(mapOfDocumentLog);
        	DataBase.executeBatch(FUB,10);
        test.stopTest();
    } 
    @isTest public static void Strength1NotNull(){
        List<Cycle__c> listCycle = new List<Cycle__c>();
        for(Cycle__c cyc : [SELECT Id, Brand_1_Free_Strength_3__c, Brand_2_Free_Strength_3__c FROM Cycle__c]){
            cyc.Brand_1_Free_Strength_3__c =null;
            cyc.Brand_2_Free_Strength_3__c =null;
            cyc.Brand_1_Free_Strength_2__c =null;
            cyc.Brand_2_Free_Strength_2__c =null;
            listCycle.add(cyc);
        }
        update listCycle;
        map<id,Document_Log__c> mapOfDocumentLog = new map<id,Document_Log__c>();
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
              	 AND Document__r.Owner.Profile.Name = 'Patient Connect Care Coordinator'
            ]  ){
                //AND CreatedDate > :dt
                mapOfDocumentLog.put(dl.Document__c, dl );
            }
      //  mapOfDocumentLog = new map<id,Document_Log__c>();
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new FileUploaderHandlerMock());
       	 	//HttpResponse res = FileUploaderHandler.testResponse();
       	 	FileUploaderBatch FUB = new FileUploaderBatch(mapOfDocumentLog);
        	DataBase.executeBatch(FUB,10);
        test.stopTest();
    } 
    
    @isTest public static void  brand1Paidand2Free(){
        List<FileUploaderHandler.FileWrapper> listOfFileWrappers = getAllRelatedRecords();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FileUploaderHandlerMock());
         // Create File Request
        Http h = new Http();        
        HttpRequest req1 = new HttpRequest();
        req1.setEndpoint('https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart&supportsTeamDrives=true');
        req1.setMethod('POST');
        req1.setBody('{"name":"test file","id":"10D7OsUFVariT5Ghe3CYV7akLjLZa00PY","mimeType":"application/pdf",parents":["1KGRBDAbYvcHZoKz9H76IRA8dy2QblhFu"],"teamDriveId":"0AGj2ssL2WNiVUk9PVA"}');
        HttpResponse res1 = h.send(req1);
        System.assertEquals('{"name":"test file","id":"10D7OsUFVariT5Ghe3CYV7akLjLZa00PY","mimeType":"application/pdf",parents":["1KGRBDAbYvcHZoKz9H76IRA8dy2QblhFu"],"teamDriveId":"0AGj2ssL2WNiVUk9PVA"}', res1.getBody());
    	test.stopTest();
    } 
}
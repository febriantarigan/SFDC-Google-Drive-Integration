@istest
public class TxtFileGeneratorHandlerTest {
	 @testSetup 
    static void setup() {
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
        Document__c document = new Document__c(Scheme__c=scheme.id,RecordTypeId=docManualUploadRT,Affiliate__c='TW',Document_Category__c='FOC Application Form');
        insert document;
        Document_Log__c documentLog = new Document_Log__c(Document__c=document.id, Cycle_Lookup__c=cycle.id, Account__c=acc.id, Coverage__c=progCoverage.id, Program__c=cs.id);
        insert documentLog;
        //brand 1 and brand 2 free
        Cycle__c cycle2 = new Cycle__c(Brand_1__c='Kadcyla',Brand_1_Type__c='Free', Brand_1_Free_Unit_1__c=1, Brand_2__c='Kadcyla',Brand_2_Type__c='Free', Brand_2_Free_Unit_1__c=1, Program_Coverage__c=progCoverage.id, Brand_1_Free_Strength_1__c=100,Brand_1_Free_Strength_2__c=120,Brand_1_Free_Strength_3__c=140, Brand_2_Free_Strength_1__c=100,Brand_2_Free_Strength_2__c=120,Brand_2_Free_Strength_3__c=140);
        insert cycle2;
        Document__c document2 = new Document__c(Scheme__c=scheme.id,RecordTypeId=docManualUploadRT,Affiliate__c='TW',Document_Category__c='FOC Application Form');
        insert document2;
        Document_Log__c documentLog2 = new Document_Log__c(Document__c=document2.id, Cycle_Lookup__c=cycle2.id, Account__c=acc.id, Coverage__c=progCoverage.id, Program__c=cs.id);
        insert documentLog2;
        //brand 1 free
        Cycle__c cycle3 = new Cycle__c(Brand_1__c='Kadcyla',Brand_1_Type__c='Free',Program_Coverage__c=progCoverage.id, Brand_1_Free_Unit_1__c=1, Brand_1_Free_Strength_1__c=100,Brand_1_Free_Strength_2__c=120,Brand_1_Free_Strength_3__c=140);
        insert cycle3;
        Document__c document3 = new Document__c(Scheme__c=scheme.id,RecordTypeId=docManualUploadRT,Affiliate__c='TW',Document_Category__c='FOC Application Form');
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
    @isTest public static void Strength1NotNull(){
        Set<Id> setOfCycleIds = new Set<Id>();
        for(Cycle__c cyc : [SELECT Id FROM Cycle__c]){
            setOfCycleIds.add(cyc.id);
        }
        
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new FileUploaderHandlerMock());
       	 	//HttpResponse res = FileUploaderHandler.testResponse();
       	 	TxtFileGeneratorBatch FUB = new TxtFileGeneratorBatch(setOfCycleIds);
        	DataBase.executeBatch(FUB);
        test.stopTest();
    } 
    
    @isTest public static void testMock(){
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
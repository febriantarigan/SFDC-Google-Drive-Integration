/*********************************************************************************
Class Name      : TxtFileGeneratorBatch
Description     : Batch class to generate txt file based on user action on cycle list view
Created By      : FEBRIAN NEDSENDA RIZKY
Created Date    : November 15, 2018
Modification Log:
---------------------------------------------------------------------------------- 
Developer                   Date                   Description
-----------------------------------------------------------------------------------            
Febrian Nedsenda Rizky		November 15, 2018      Initial Version
*********************************************************************************/
global class TxtFileGeneratorBatch implements Database.Batchable<sObject>,Database.AllowsCallouts{
    public Set<Id> setOfCycleProductIds;
    public map<Id,Cycle_Product__c> mapOfCycleProducts;

    /*********************************************************************************
    CONSTRUCTOR
    Description    : Constructor to fetch map from scheduler
    Input Params   : Map <Id of document, document log>
    *********************************************************************************/
    public TxtFileGeneratorBatch ( Set<Id> setOfCycleIds ){
        mapOfCycleProducts = new map<Id,Cycle_Product__c>();
        setOfCycleProductIds = new Set<Id>();
        for(Cycle_Product__c cycleProduct : [SELECT Id FROM Cycle_Product__c WHERE Cycle__c IN:setOfCycleIds AND Is_Empty__c = false]){
        	setOfCycleProductIds.add(cycleProduct.id);
        }
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        
		return Database.getQueryLocator('Select Cycle__r.Program_Coverage__r.Program__r.Recipient_1__r.Name, Cycle__r.Program_Coverage__r.Program__r.Recipient_2__r.Name, Cycle__r.Program_Coverage__r.Program__r.Recipient_1_Phone_Number__c, Cycle__r.Program_Coverage__r.Program__r.Recipient_2_Phone_Number__c, id, Customer_Code__c, Cycle__r.Name, Cycle__r.FOC_Process_Date_Text__c, Order_Type_1__c, Order_Type_2__c, Delivery_Date_Text__c, Order_Type_3__c, Cycle__r.Program_Coverage__r.Scheme__r.Scheme_Code__c, Cycle__r.Program_Coverage__r.Scheme__r.Name, Cycle__r.Program_Coverage__r.Scheme__r.Scheme_Description__c, Product_Code__c, SAP_Code__c, Quantity__c, UoM__c, Warehouse__c, WBS__c, Cycle__r.Program_Coverage__r.Program__r.Hospital__c,  Cycle__r.Program_Coverage__r.Program__r.Recipient_1__c, Cycle__r.Program_Coverage__r.Program__r.Rcpnt_1_Primary_Phone_Number__c, Cycle__r.Program_Coverage__r.Program__r.Rcnpt_1_Primary_Mobile__c, Cycle__r.Program_Coverage__r.Program__r.Rcnpt_1_Secondary_Phone_Number__c, Cycle__r.Program_Coverage__r.Program__r.Rcnpt_1_Secondary_Mobile__c, Cycle__r.Patient__r.Patient_s_Initials__c, Cycle__r.Program_Coverage__r.Program__r.Case_Number__c, Cycle__r.Program_Coverage__r.Program__r.Recipient_2__c, Cycle__r.Program_Coverage__r.Program__r.Rcpnt_2_Primary_Phone__c, Cycle__r.Program_Coverage__r.Program__r.Rcpnt_2_Primary_Mobile__c, Cycle__r.Program_Coverage__r.Program__r.Rcpnt_2_Secondary_Phone__c, Cycle__r.Program_Coverage__r.Program__r.Rcnpt_2_Secondary_Mobile__c, Cycle__r.Program_Coverage__r.Program__r.Recipient_Note__c, Cycle__r.Program_Coverage__r.Program__r.Account_Specialty__c, Cycle__r.Program_Coverage__r.Program__r.Physician__c, Cycle__r.Initial_Approver_Name__c, Cycle__r.Program_Coverage__r.Program__r.Full_Delivery_Address__c, Cycle__r.Program_Coverage__r.Program__r.Delivery_City__c, Cycle__r.Cycle_Remarks__c FROM Cycle_Product__c WHERE Id IN: setOfCycleProductIds');
    }
    
    global void execute(Database.BatchableContext BC, List<Cycle_Product__c> scope){
        TxtFileGeneratorHandler.generateFile(scope);
    }
    
    global void finish(Database.BatchableContext BC){    
        
    }
}
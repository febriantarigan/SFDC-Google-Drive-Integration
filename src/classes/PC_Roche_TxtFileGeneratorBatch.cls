/*********************************************************************************
Class Name      : PC_Roche_TxtFileGeneratorBatch
Description     : Batch class to generate txt file based on user action on cycle list view
Created By      : Transition Technology Managed Services
Created Date    : November 15, 2018
Modification Log:
---------------------------------------------------------------------------------- 
Developer                   Date                   Description
-----------------------------------------------------------------------------------            
Febrian Nedsenda Rizky    November 15, 2018      Initial Version
*********************************************************************************/
global class PC_Roche_TxtFileGeneratorBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful{
    public Set<Id> setOfCycleProductIds;
    public map<Id,PC_Roche_Cycle_Product__c> mapOfCycleProducts;
    PC_Roche_TxtFileGeneratorHandler txtHandler;

    /*********************************************************************************
    CONSTRUCTOR
    Description    : Constructor to fetch map from scheduler
    Input Params   : Map <Id of document, document log>
    *********************************************************************************/
    public PC_Roche_TxtFileGeneratorBatch ( Set<Id> setOfCycleIds ){
        txtHandler= new PC_Roche_TxtFileGeneratorHandler();
        mapOfCycleProducts = new map<Id,PC_Roche_Cycle_Product__c>();
        setOfCycleProductIds = new Set<Id>();
        for(PC_Roche_Cycle_Product__c cycleProduct : [SELECT Id FROM PC_Roche_Cycle_Product__c WHERE PC_Roche_Cycle__c IN:setOfCycleIds AND PC_Roche_Is_Empty__c = false]){
          setOfCycleProductIds.add(cycleProduct.id);
        }
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        
		return Database.getQueryLocator('Select PC_Roche_Cycle__r.PC_Roche_Program_Coverage__r.PatientConnect__PC_Program__r.PC_Roche_Recipient_1__r.Name, PC_Roche_Cycle__r.PC_Roche_Program_Coverage__r.PatientConnect__PC_Program__r.PC_Roche_Recipient_2__r.Name, PC_Roche_Cycle__r.PC_Roche_Program_Coverage__r.PatientConnect__PC_Program__r.PC_Roche_Recipient_1_Phone_Number__c, PC_Roche_Cycle__r.PC_Roche_Program_Coverage__r.PatientConnect__PC_Program__r.PC_Roche_Recipient_2_Phone_Number__c, id, PC_Roche_Customer_Code__c, PC_Roche_Cycle__r.Name, PC_Roche_Cycle__r.PC_Roche_FOC_Process_Date_Text__c, PC_Roche_Order_Type_1__c, PC_Roche_Order_Type_2__c, PC_Roche_Delivery_Date_Text__c, PC_Roche_Order_Type_3__c, PC_Roche_Cycle__r.PC_Roche_Program_Coverage__r.PC_Roche_Scheme__r.PC_Roche_Scheme_Code__c, PC_Roche_Cycle__r.PC_Roche_Program_Coverage__r.PC_Roche_Scheme__r.Name, PC_Roche_Cycle__r.PC_Roche_Program_Coverage__r.PC_Roche_Scheme__r.PC_Roche_Scheme_Description__c, PC_Roche_Product_Code__c, PC_Roche_SAP_Code__c, PC_Roche_Quantity__c, PC_Roche_UoM__c, PC_Roche_Warehouse__c, PC_Roche_WBS__c, PC_Roche_Cycle__r.PC_Roche_Program_Coverage__r.PatientConnect__PC_Program__r.PC_Roche_Hospital__c,  PC_Roche_Cycle__r.PC_Roche_Program_Coverage__r.PatientConnect__PC_Program__r.PC_Roche_Recipient_1__c, PC_Roche_Cycle__r.PC_Roche_Program_Coverage__r.PatientConnect__PC_Program__r.PC_Roche_Rcpnt_1_Primary_Phone_Number__c, PC_Roche_Cycle__r.PC_Roche_Program_Coverage__r.PatientConnect__PC_Program__r.Pc_Roche_Rcnpt_1_Primary_Mobile__c, PC_Roche_Cycle__r.PC_Roche_Program_Coverage__r.PatientConnect__PC_Program__r.PC_Roche_Rcnpt_1_Secondary_Phone_Number__c, PC_Roche_Cycle__r.PC_Roche_Program_Coverage__r.PatientConnect__PC_Program__r.PC_Roche_Rcnpt_1_Secondary_Mobile__c, PC_Roche_Cycle__r.PC_Roche_Patient__r.PC_Roche_Patient_s_Initials__c, PC_Roche_Cycle__r.PC_Roche_Program_Coverage__r.PatientConnect__PC_Program__r.PC_Roche_Case_Number__c, PC_Roche_Cycle__r.PC_Roche_Program_Coverage__r.PatientConnect__PC_Program__r.PC_Roche_Recipient_2__c, PC_Roche_Cycle__r.PC_Roche_Program_Coverage__r.PatientConnect__PC_Program__r.Pc_Roche_Rcpnt_2_Primary_Phone__c, PC_Roche_Cycle__r.PC_Roche_Program_Coverage__r.PatientConnect__PC_Program__r.PC_Roche_Rcpnt_2_Primary_Mobile__c, PC_Roche_Cycle__r.PC_Roche_Program_Coverage__r.PatientConnect__PC_Program__r.PC_Roche_Rcpnt_2_Secondary_Phone__c, PC_Roche_Cycle__r.PC_Roche_Program_Coverage__r.PatientConnect__PC_Program__r.PC_Roche_Rcnpt_2_Secondary_Mobile__c, PC_Roche_Cycle__r.PC_Roche_Program_Coverage__r.PatientConnect__PC_Program__r.Recipient_Note__c, PC_Roche_Cycle__r.PC_Roche_Program_Coverage__r.PatientConnect__PC_Program__r.PC_Roche_Account_Specialty__c, PC_Roche_Cycle__r.PC_Roche_Program_Coverage__r.PatientConnect__PC_Program__r.PC_Roche_Physician__c, PC_Roche_Cycle__r.PC_Roche_Initial_Approver_Name__c, PC_Roche_Cycle__r.PC_Roche_Program_Coverage__r.PatientConnect__PC_Program__r.PC_Roche_Full_Delivery_Address__c, PC_Roche_Cycle__r.PC_Roche_Program_Coverage__r.PatientConnect__PC_Program__r.PC_Roche_Delivery_City__c, PC_Roche_Cycle__r.Pc_Roche_Cycle_Remarks__c,PC_Roche_Cycle__r.PC_Roche_Program_Coverage__r.PatientConnect__PC_Program__r.Location_Specialty__c,PC_Roche_Cycle__r.PC_Roche_Program_Coverage__r.PatientConnect__PC_Program__r.PC_Roche_Delivery_Location__r.Name' +
                ' FROM PC_Roche_Cycle_Product__c WHERE Id IN: setOfCycleProductIds');
    }
    
    global void execute(Database.BatchableContext BC, List<PC_Roche_Cycle_Product__c> scope){
        txtHandler.generateFile(scope);
    }
    
    global void finish(Database.BatchableContext BC){    
        
    }
}

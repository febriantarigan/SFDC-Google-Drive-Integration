/**
 * Created by kasprzym on 2019-03-22.
 */

global abstract with sharing class PC_Roche_TxtFileGeneratorBase {
    public List<GDrive_File_Upload_Error__c> listOfErrors;

    /*********************************************************************************
Method Name    : forceLength
Description    : to set length and append tab space on text
Input Params   : string, desired length
Return Type    : String
*********************************************************************************/
    protected string forceLength( string aFieldValue, integer aLength ){
        if(aFieldValue==null)
            aFieldValue ='';
        return (aFieldValue.length() > aLength) ? '\t'+ aFieldValue.left( aLength ):'\t'+aFieldValue;
    }

    /*********************************************************************************
Method Name    : removeSpecialCharacters
Description    : to remove special characters based on set unwated characters method
Input Params   : String
Return Type    : String
*********************************************************************************/
    protected string removeSpecialCharacters ( string aFieldValue ){
        for( string keyStoke : UnwantedCharacters() )
            aFieldValue.replace(keyStoke , '' );
        return aFieldValue;
    }

    /*********************************************************************************
Method Name    : UnwantedCharacters
Description    : List of characters that want to be removed
Input Params   : String
Return Type    : String
*********************************************************************************/
    protected set<string> UnwantedCharacters (){
        set<string> setOfCharString = new set<string>();
        setOfCharString.add('\n');
        setOfCharString.add('<br>');
        return setOfCharString;
    }

    /*********************************************************************************
Method Name    : addDummy
Description    : append and tab space
Input Params   : String
Return Type    : String
*********************************************************************************/
    protected string addDummy ( string aFieldValue ){
        return aFieldValue = aFieldValue + '\t ';
    }

    /*********************************************************************************
Method Name    : emptifyNullValue
Description    : check if field value is ull will return empty string
Input Params   : String
Return Type    : String
*********************************************************************************/
    protected string emptifyNullValue(String aFieldValue){
        if(aFieldValue==null)
            aFieldValue ='';
        return aFieldValue;
    }

    /*********************************************************************************
Method Name    : containsChineseCharacters
Description    : to check if inputted string contains chinese characters
Input Params   : String
Return Type    : Boolean
*********************************************************************************/
    protected Boolean containsChineseCharacters(String InputString){
        Pattern p = Pattern.compile('\\p{IsHan}');
        Matcher m = p.matcher( InputString );
        return m.find();
    }


    /*********************************************************************************
Method Name    : createSI
Description    : concatenate all field to create SI
Input Params   : Cycle product
Return Type    : String
*********************************************************************************/
    protected string createSI(PC_Roche_Cycle_Product__c str){
        String SI ='';
        //7,8,_,9
        SI += emptifyNullValue(str.PC_Roche_Order_Type_3__c);
        SI += emptifyNullValue(str.PC_Roche_Cycle__r.PC_Roche_Program_Coverage__r.PC_Roche_Scheme__r.PC_Roche_Scheme_Code__c)+'_';
        SI += emptifyNullValue(str.PC_Roche_Cycle__r.PC_Roche_Program_Coverage__r.PC_Roche_Scheme__r.Name);
        //[19,20,27,28,33]
        //Recipient 1
        SI += '['+emptifyNullValue(str.PC_Roche_Cycle__r.PC_Roche_Program_Coverage__r.PatientConnect__PC_Program__r.PC_Roche_Recipient_1__r.Name);
        SI += emptifyNullValue(str.PC_Roche_Cycle__r.PC_Roche_Program_Coverage__r.PatientConnect__PC_Program__r.PC_Roche_Recipient_1_Phone_Number__c);
        //Recipient 2
        SI += emptifyNullValue(str.PC_Roche_Cycle__r.PC_Roche_Program_Coverage__r.PatientConnect__PC_Program__r.PC_Roche_Recipient_2__r.Name);
        SI += emptifyNullValue(str.PC_Roche_Cycle__r.PC_Roche_Program_Coverage__r.PatientConnect__PC_Program__r.PC_Roche_Recipient_2_Phone_Number__c);
        SI += emptifyNullValue(str.PC_Roche_Cycle__r.PC_Roche_Program_Coverage__r.PatientConnect__PC_Program__r.Recipient_Note__c)+']';
        //39
        SI += emptifyNullValue(str.PC_Roche_Cycle__r.Pc_Roche_Cycle_Remarks__c);
        //25,26
        SI += '['+emptifyNullValue(str.PC_Roche_Cycle__r.PC_Roche_Patient__r.PC_Roche_Patient_s_Initials__c);
        SI += emptifyNullValue(str.PC_Roche_Cycle__r.PC_Roche_Program_Coverage__r.PatientConnect__PC_Program__r.PC_Roche_Case_Number__c)+']';
        //34,35
        SI += '['+emptifyNullValue(str.PC_Roche_Cycle__r.PC_Roche_Program_Coverage__r.PatientConnect__PC_Program__r.Location_Specialty__c);
        SI += emptifyNullValue(str.PC_Roche_Cycle__r.PC_Roche_Program_Coverage__r.PatientConnect__PC_Program__r.PC_Roche_Physician__c)+']';
        system.debug('SI =>'+SI);
        return SI;
    }

    /*********************************************************************************
Method Name    : createAddr
Description    : concatenate all field to create ADDR
Input Params   : Cycle Product
Return Type    : String
*********************************************************************************/
    protected string createAddr(PC_Roche_Cycle_Product__c str){
        String Addr ='';
        //18+$$+37+$$
       // Addr += removeSpecialCharacters(emptifyNullValue(str.PC_Roche_Cycle__r.PC_Roche_Program_Coverage__r.PatientConnect__PC_Program__r.PC_Roche_Hospital__c))+'$$';
        Addr += removeSpecialCharacters(emptifyNullValue(str.PC_Roche_Cycle__r.PC_Roche_Program_Coverage__r.PatientConnect__PC_Program__r.PC_Roche_Delivery_Location__r.Name))+'$$';
        Addr += removeSpecialCharacters(emptifyNullValue(str.PC_Roche_Cycle__r.PC_Roche_Program_Coverage__r.PatientConnect__PC_Program__r.PC_Roche_Full_Delivery_Address__c))+'$$';
        return Addr;
    }

    /*********************************************************************************
Method Name    : createErrorLog
Description    : Create Error Log on GDrive File Upload Error object
Input Params   : String method name, Error Message
Return Type    : N/A
*********************************************************************************/
    protected void createErrorLog(String methodName, String errorMessage){
        GDrive_File_Upload_Error__c log = new GDrive_File_Upload_Error__c();
        log.Error_Message__c = errorMessage;
        log.Error_Datetime__c = system.now();
        log.Method_Name__c = methodName;
        log.Class_Name__c = 'PC_Roche_TxtFileGeneratorHandler';
        listOfErrors.add(log);
    }

}
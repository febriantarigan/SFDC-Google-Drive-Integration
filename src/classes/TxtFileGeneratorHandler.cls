/*********************************************************************************
Class Name      : TxtFileGeneratorHandler
Description     : Handler for TxtFileGeneratorBatch, Upload document to Team Drive and send Email with attachment
Created By      : Transition Technology Managed Services
Created Date    : November 15, 2018
Modification Log:
---------------------------------------------------------------------------------- 
Developer                   Date                   Description
-----------------------------------------------------------------------------------            
Febrian Nedsenda Rizky		November 15, 2018      Initial Version
*********************************************************************************/
public class TxtFileGeneratorHandler {
    Private static List<GDrive_File_Upload_Error__c> listOfErrors;
    private static String FinalString = '';
    
    /*********************************************************************************
Method Name    : accessToken
Description    : Generate google access token through google service account
Input Params   : N/A
Return Type    : String      
*********************************************************************************/
    private static string accessToken(){  
        System.debug('TxtFileGeneratorHandler Generate Google Access Token...');
        String token = '';
        if (Test.isRunningTest()) {
            token = 'test-token-will-not-be-used';  
        } else { 
            //fetch service account credential on custom metadata type
            GDriveForSalesforce__mdt gDriveMDT = [SELECT Id, Service_Account_Id__c, Token_Endpoint__c, Scopes__c 
                                                  FROM GDriveForSalesforce__mdt WHERE DeveloperName ='TW_TXT_File_Generator' LIMIT 1];
            Auth.JWT jwt = new Auth.JWT();
            jwt.setAud( gDriveMDT.Token_Endpoint__c ); 
            jwt.setIss( gDriveMDT.Service_Account_Id__c );
            jwt.setAdditionalClaims( new Map<String, Object>{ 'scope' => gDriveMDT.Scopes__c } );
            
            // get JWS from certificate and key management api name (GDrive_Connector)
            Auth.JWS jws = new Auth.JWS( jwt, 'GDrive_Connector' ); 
            Auth.JWTBearerTokenExchange bearer = new Auth.JWTBearerTokenExchange( gDriveMDT.Token_Endpoint__c, jws );
            token = bearer.getAccessToken();
            System.debug('Completed TxtFileGeneratorHandler Google Access Token Generation => '+token);
        }
        return token;
    }
    
    /*********************************************************************************
Method Name    : generateFile
Description    : Generating txt file
Input Params   : List of Cycle Products 
Return Type    : N/A      
*********************************************************************************/ 
    public static void generateFile(List<Cycle_Product__c> listOfCycleProducts){
        listOfErrors = new List<GDrive_File_Upload_Error__c>();
        String googleAccessToken = accessToken();
        Blob file = prepareFile(listOfCycleProducts);
        String folderId = searchOrCreateFolder(googleAccessToken);
        Datetime dt = system.now();
        String day = dt.day() < 10 ? '0'+String.valueOf(dt.day()) : String.valueOf(dt.day());
        String month = dt.month() < 10 ? '0'+String.valueOf(dt.month()) : String.valueOf(dt.month());
        String year = String.valueOf(dt.year());
        String hour = dt.hour() < 10 ? '0'+String.valueOf(dt.hour()) : String.valueOf(dt.hour());
        String minute = dt.minute() < 10 ? '0'+String.valueOf(dt.minute()) : String.valueOf(dt.minute());
        String second = dt.second() < 10 ? '0'+String.valueOf(dt.second()) : String.valueOf(dt.second());
        //document name format (dd-mm-yyyy hh:mm:ss)
        String documentName = day+'-'+month+'-'+year+' '+hour+':'+minute+':'+second;
        
        uploadFile(googleAccessToken, documentName, file, folderId);
        //
        sendFileByEmail(documentName, file, new List<String>{Label.TXT_FILE_GENERATOR_EMAIL});
        if(listOfErrors.size()>0)
            insert listOfErrors;
    }
    
    /*********************************************************************************
Method Name    : prepareFile
Description    : Prepare txt file based on related records
Input Params   : List of Cycle Products
Return Type    : Blob      
*********************************************************************************/ 
    public static Blob prepareFile(List<Cycle_Product__c> listOfCycleProducts){
        system.debug(listOfCycleProducts);
        List<Cycle_Product__c> listOfUpdatedCycleProducts = new List<Cycle_Product__c>();
        for(Cycle_Product__c str : listOfCycleProducts){
            FinalString += ' '; //first dummy
            FinalString += forceLength( str.Customer_Code__c, 10 );system.debug('col 1 : '+FinalString);
            FinalString = addDummy(FinalString);
            FinalString += forceLength( str.Cycle__r.Name, 20 );system.debug('col 2 : '+FinalString);
            FinalString += forceLength( str.Cycle__r.FOC_Process_Date_Text__c,8 );system.debug('col 3 : '+FinalString);
            FinalString += forceLength( str.Order_Type_1__c,4);system.debug('col 4 : '+FinalString);
            FinalString += forceLength( str.Order_Type_2__c,3 );system.debug('col 5 : '+FinalString);
            FinalString += forceLength( str.Delivery_Date_Text__c,8);system.debug('col 6 : '+FinalString);
            SplitWrapper SI1 = getSplittedString(createSI(str), 0, 120);
            SplitWrapper SI2 = getSplittedString(createSI(str), SI1.nextCharacter, 30);
            SplitWrapper SI3 = getSplittedString(createSI(str), SI1.nextCharacter+SI2.nextCharacter, 40);
            SplitWrapper SI4 = getSplittedString(createSI(str), SI1.nextCharacter+SI2.nextCharacter+SI3.nextCharacter, 40);
            SplitWrapper SI5 = getSplittedString(createSI(str), SI1.nextCharacter+SI2.nextCharacter+SI3.nextCharacter+SI4.nextCharacter, 40);
            SplitWrapper SI6 = getSplittedString(createSI(str), SI1.nextCharacter+SI2.nextCharacter+SI3.nextCharacter+SI4.nextCharacter+SI5.nextCharacter, 40);
            SplitWrapper SI7 = getSplittedString(createSI(str), SI1.nextCharacter+SI2.nextCharacter+SI3.nextCharacter+SI4.nextCharacter+SI5.nextCharacter+SI6.nextCharacter, 40);
            SplitWrapper ADDR1 = getSplittedString(createAddr(str), 0, 60);
            SplitWrapper ADDR2 = getSplittedString(createAddr(str), ADDR1.nextCharacter, 40);
            FinalString += '\t'+SI1.splittedString;
            FinalString += '\t'+SI2.splittedString;
            FinalString += forceLength(str.Product_Code__c,18);system.debug('col 12 : '+FinalString);
            FinalString += forceLength(str.SAP_Code__c,4);system.debug('col 13 : '+FinalString);
            FinalString = addDummy(FinalString);
            FinalString += forceLength(String.valueOf(str.Quantity__c.setScale(0)),15);system.debug('col 14 : '+FinalString);
            FinalString += forceLength(str.UoM__c,3);system.debug('col 15 : '+FinalString);
            FinalString += forceLength(str.Warehouse__c,4);system.debug('col 16 : '+FinalString);
            FinalString += forceLength(str.WBS__c,24);system.debug('col 17 : '+FinalString);
            FinalString += '\t'+SI3.splittedString;
            FinalString += '\t'+SI4.splittedString;
            FinalString += '\t'+SI5.splittedString;
            FinalString += '\t'+SI6.splittedString;
            FinalString += '\t'+ADDR1.splittedString;
            FinalString += '\t'+SI7.splittedString;
            FinalString += '\t'+ADDR2.splittedString;
            FinalString = addDummy(FinalString);
            FinalString = addDummy(FinalString);
            FinalString = addDummy(FinalString);
            FinalString += '\n'; //new line for each cycle product
        }
        Blob file = Blob.valueOf(FinalString);
        return file;
    }
    
    /*********************************************************************************
Method Name    : uploadFile
Description    : Upload file to google drive
Input Params   : Google Access Token, document name, file blob, parent Id
Return Type    : N/A      
*********************************************************************************/    
    private static void uploadFile(String googleAccessToken, String documentName, Blob file, String parentId){
        system.debug('TxtFileGeneratorHandler UPLOAD FILE METHOD...');
        GDriveForSalesforce__mdt gDriveMDT = [SELECT Id, Service_Account_Id__c, Token_Endpoint__c, Scopes__c, Team_Drive_Id__c FROM GDriveForSalesforce__mdt WHERE DeveloperName ='TW_TXT_File_Generator' LIMIT 1];
        String teamDriveId = gDriveMDT.Team_Drive_Id__c;
        //boundary that required for uploading file to google drive
        String boundary = 'END_OF_PART';
        String delimiter = '\r\n--' + boundary +'\r\n';
        String close_delim = '\r\n--' + boundary + '--';
        FileRequestClass frc = new FileRequestClass(documentName, 'text/plain', teamDriveId, parentId);
        String bodyEncoded = EncodingUtil.base64Encode(file); //encode blob to string
        String requestBody = json.serialize(frc); //create request body
        //create HTTP Request Body
        String body = delimiter+'Content-Type: application/json\r\n\r\n'+requestBody+delimiter+'Content-Type: ' + frc.mimeType + '\r\n'+'Content-Transfer-Encoding: base64\r\n'+'\r\n'+bodyEncoded+close_delim;
        
        Http h = new Http();
        HttpRequest createFileRequest = new HttpRequest();
        createFileRequest.setHeader('Authorization', 'Bearer ' + googleAccessToken);
        createFileRequest.setHeader('Content-length', String.valueOf(body.length()));
        createFileRequest.setHeader('Content-Type', 'multipart/mixed; boundary="'+boundary+'"');
        createFileRequest.setEndpoint('https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart&supportsTeamDrives=true');  
        createFileRequest.setBody(body);       
        createFileRequest.setMethod('POST');
        createFileRequest.setTimeout(120000);
        HttpResponse createFileResponse = h.send(createFileRequest);
        system.debug('CREATE FILE BODY => '+createFileResponse.getBody());
        if(createFileResponse.getStatusCode() != 200)
            createErrorLog('uploadFile', createFileResponse.getBody());
        System.debug('Completed TxtFileGeneratorHandler UPLOAD FILE METHOD...');
    }
    
    /*********************************************************************************
Method Name    : searchOrCreateFolder
Description    : To search folder on root, if not exist it will create new folder
Input Params   : Google Access Token
Return Type    : String (folderId)     
*********************************************************************************/  
    private static string searchOrCreateFolder(String googleAccessToken){
        system.debug('TxtFileGeneratorHandler SEARCH FOLDER METHOD...');
        GDriveForSalesforce__mdt gDriveMDT = [SELECT Id, Service_Account_Id__c, Token_Endpoint__c, Scopes__c, Team_Drive_Id__c FROM GDriveForSalesforce__mdt WHERE DeveloperName ='TW_TXT_File_Generator' LIMIT 1];
        String teamDriveId = gDriveMDT.Team_Drive_Id__c;
        Date dt = system.today();
        String month = dt.month() < 10 ? '0'+String.valueOf(dt.month()) : String.valueOf(dt.month());
        String year = String.valueOf(dt.year());
        String folderName = year+month;
        //Set endpoint query parameter
        String query = 'mimeType = \'application/vnd.google-apps.folder\' and trashed = false and name = \''+folderName+'\'';
        String query2 = System.EncodingUtil.urlEncode(query, 'UTF-8');
        
        Http h = new Http();
        HttpRequest searchFolderRequest = new HttpRequest();
        searchFolderRequest.setEndpoint('https://www.googleapis.com/drive/v3/files?corpora=teamDrive&includeTeamDriveItems=true&supportsTeamDrives=true&teamDriveId='+teamDriveId+'&q='+query2);
        searchFolderRequest.setMethod('GET');
        searchFolderRequest.setHeader('Authorization', 'Bearer ' + googleAccessToken);
        searchFolderRequest.setTimeout(120000);
        HttpResponse searchFolderResponse = h.send(searchFolderRequest);
        
        if(searchFolderResponse.getStatusCode() == 200){
            JSONParser parser = JSON.createParser(searchFolderResponse.getBody());
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'id')) {
                    parser.nextToken();
                    return parser.getText();
                }
            }
            system.debug('SEARCH FOLDER BODY => '+searchFolderResponse.getBody());
            System.debug('Completed SEARCH FILE METHOD...');
            
            system.debug('CREATE FOLDER METHOD => '+folderName);
            //Prepare HTTP request body
            FileRequestClass fc = new FileRequestClass(folderName, 'application/vnd.google-apps.folder', teamDriveId, teamDriveId);
            String messageBody = Json.serialize(fc);
            
            HttpRequest createFolderRequest = new HttpRequest();
            createFolderRequest.setMethod('POST');
            createFolderRequest.setHeader('Content-Type', 'application/json');
            createFolderRequest.setHeader('Content-length', String.valueOf(messageBody.length()));
            createFolderRequest.setHeader('Authorization', 'Bearer ' + googleAccessToken);
            createFolderRequest.setEndpoint('https://www.googleapis.com/drive/v3/files?supportsTeamDrives=true');  
            createFolderRequest.setTimeout(120000);
            createFolderRequest.setBody(messageBody);
            HttpResponse createFolderResponse = h.send(createFolderRequest);
            
            if(createFolderResponse.getStatusCode() == 200){
                JSONParser parser2 = JSON.createParser(createFolderResponse.getBody());
                while (parser2.nextToken() != null) {
                    if ((parser2.getCurrentToken() == JSONToken.FIELD_NAME) && (parser2.getText() == 'id')) {
                        parser2.nextToken();
                        return parser2.getText();
                    }
                }
                system.debug('SEARCH FOLDER BODY => '+createFolderResponse.getBody());
            }
            else
                createErrorLog('searchOrCreateFolder(create)', createFolderResponse.getBody());
            System.debug('Completed CREATE FILE METHOD...');
        }
        else
            createErrorLog('searchOrCreateFolder(search)', searchFolderResponse.getBody());
        System.debug('Completed TxtFileGeneratorHandler SEARCH OR CREATE FILE METHOD...');
        return 'Error';
    }
    
    /*********************************************************************************
Method Name    : forceLength
Description    : to set length and append tab space on text
Input Params   : string, desired length
Return Type    : String    
*********************************************************************************/  
    private static string forceLength( string aFieldValue, integer aLength ){
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
    private static string removeSpecialCharacters ( string aFieldValue ){
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
    private static set<string> UnwantedCharacters (){
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
    private static string addDummy ( string aFieldValue ){
        return aFieldValue = aFieldValue + '\t ';
    } 
    
    /*********************************************************************************
Method Name    : emptifyNullValue
Description    : check if field value is ull will return empty string
Input Params   : String
Return Type    : String    
*********************************************************************************/ 
    private static string emptifyNullValue(String aFieldValue){
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
    private static Boolean containsChineseCharacters(String InputString){
        Pattern p = Pattern.compile('\\p{IsHan}');
        Matcher m = p.matcher( InputString );
        return m.find();
    }
    
    /*********************************************************************************
Method Name    : containsChineseCharacters
Description    : to check if inputted string contains chinese characters
Input Params   : String
Return Type    : Boolean    
*********************************************************************************/ 
    private static SplitWrapper getSplittedString(String text, Integer startCharacter, Integer maxByteLength){
        system.debug(startCharacter+'<'+text.length());
        if(startCharacter<text.length()){
            String currentSI = text.substring(startCharacter);
            String[] processedSI = currentSI.split('');
            String splittedSI='';
            Integer characterCounter=0;
            Integer byteLength =0;
            for(Integer i = 0; byteLength<maxByteLength && i<processedSi.size();i++){
                if(containsChineseCharacters(processedSI[i]) && (byteLength+2)>maxByteLength){
                    byteLength+=2;
                }
                else if(containsChineseCharacters(processedSI[i]) && (byteLength+2)<=maxByteLength){
                    byteLength+=2;
                    characterCounter++;
                    splittedSI += processedSI[i];
                }else{
                    byteLength+=1;
                    characterCounter++;
                    splittedSI += processedSI[i];
                }
            }
            return new SplitWrapper(splittedSI,characterCounter);
        }else{
            return new SplitWrapper('', 0);
        }
    }    
    /*********************************************************************************
Method Name    : createSI
Description    : concatenate all field to create SI 
Input Params   : Cycle product
Return Type    : String    
*********************************************************************************/ 
    private static string createSI(Cycle_Product__c str){
        String SI ='';
        //7,8,_,9
        SI += emptifyNullValue(str.Order_Type_3__c);
        SI += emptifyNullValue(str.Cycle__r.Program_Coverage__r.Scheme__r.Scheme_Code__c)+'_';
        SI += emptifyNullValue(str.Cycle__r.Program_Coverage__r.Scheme__r.Name);
        //[19,20,27,28,33]
        //Recipient 1
        SI += '['+emptifyNullValue(str.Cycle__r.Program_Coverage__r.Program__r.Recipient_1__r.Name);
        SI += emptifyNullValue(str.Cycle__r.Program_Coverage__r.Program__r.Recipient_1_Phone_Number__c);
        //Recipient 2
        SI += emptifyNullValue(str.Cycle__r.Program_Coverage__r.Program__r.Recipient_2__r.Name);
        SI += emptifyNullValue(str.Cycle__r.Program_Coverage__r.Program__r.Recipient_2_Phone_Number__c);
        SI += emptifyNullValue(str.Cycle__r.Program_Coverage__r.Program__r.Recipient_Note__c)+']';
        //39
        SI += emptifyNullValue(str.Cycle__r.Cycle_Remarks__c);
        //25,26
        SI += '['+emptifyNullValue(str.Cycle__r.Patient__r.Patient_s_Initials__c);
        SI += emptifyNullValue(str.Cycle__r.Program_Coverage__r.Program__r.Case_Number__c)+']';
        //34,35
        SI += '['+emptifyNullValue(str.Cycle__r.Program_Coverage__r.Program__r.Account_Specialty__c);    
        SI += emptifyNullValue(str.Cycle__r.Program_Coverage__r.Program__r.Physician__c)+']';
        system.debug('SI =>'+SI);
        return SI;
    }
    
    /*********************************************************************************
Method Name    : createAddr
Description    : concatenate all field to create ADDR
Input Params   : Cycle Product
Return Type    : String     
*********************************************************************************/
    private static string createAddr(Cycle_Product__c str){
        String Addr ='';
        //18+AD+37
        Addr += removeSpecialCharacters(emptifyNullValue(str.Cycle__r.Program_Coverage__r.Program__r.Hospital__c))+'AD';
        Addr += removeSpecialCharacters(emptifyNullValue(str.Cycle__r.Program_Coverage__r.Program__r.Full_Delivery_Address__c));
        return Addr;
    }
    
    /*********************************************************************************
Method Name    : sendFileByEmail
Description    : Send email to list of users
Input Params   : Document Name, File, List of (TO) recipients
Return Type    : N/A      
*********************************************************************************/
    private static void sendFileByEmail(String documentName, Blob file, List<String> toAddresses){
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setSubject('[FOC Order Text File] '+documentName);
        mail.setPlainTextBody('Please see find the attached text file.');
        if(file!=null){
            List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            efa.setFileName(documentName+'.txt');
            efa.setBody(file);
            fileAttachments.add(efa);
            System.debug(fileAttachments);
            mail.setFileAttachments(fileAttachments);     
        }
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }
    
    /*********************************************************************************
Method Name    : createErrorLog
Description    : Create Error Log on GDrive File Upload Error object
Input Params   : String method name, Error Message
Return Type    : N/A      
*********************************************************************************/
    private static void createErrorLog(String methodName, String errorMessage){
        GDrive_File_Upload_Error__c log = new GDrive_File_Upload_Error__c();
        log.Error_Message__c = errorMessage;
        log.Error_Datetime__c = system.now();
        log.Method_Name__c = methodName;
        log.Class_Name__c = 'TxtFileGeneratorHandler';
        listOfErrors.add(log);
    }
    
    //Wrapper class for request file to Google Drive API
    private class FileRequestClass {
        public String name; //folder name
        public String mimeType; //file type
        public String teamDriveId; // team drive id
        public List<String> parents; //parent folder id
        public FileRequestClass(String name, String mimeType, String teamDriveId, String parentId){
            this.name = name;
            this.mimeType = mimeType;
            this.teamDriveId = teamDriveId;
            this.parents = new List<String>{parentId};
                }
    }
    private class SplitWrapper{
        public String splittedString; //SI or ADDR
        public Integer nextCharacter; 
        public SplitWrapper(String splittedString, Integer nextCharacter){
            this.splittedString = splittedString;
            this.nextCharacter = nextCharacter;
        }
    }
}
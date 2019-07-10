/*********************************************************************************
Class Name      : PC_Roche_TxtFileGeneratorHandler
Description     : Handler for PC_Roche_TxtFileGeneratorBatch, Upload document to TW P360 txt files and send Email with attachment
Created By      : Transition Technology Managed Services
Created Date    : November 15, 2018
Modification Log:
---------------------------------------------------------------------------------- 
Developer                   Date                   Description
-----------------------------------------------------------------------------------            
Febrian Nedsenda Rizky		November 15, 2018      Initial Version
Febrian Nedsenda Rizky		December 5, 2018	   Change the length for SI and ADDR, Change character counting logic (Chinese character will be count as 2), Create wrapper class for character counting logic											   
Febrian Nedsenda Rizky		December 17, 2018	   Create custom label for email recipient 
Febrian Nedsenda Rizky		January 4, 2019 	   Change the Order of file generation
Febrian Nedsenda Rizky		January 10, 2019	   Add condition on SI6 (if SI6 is empty, put '.' mark)
Febrian Nedsenda Rizky		January 16, 2019	   Add Carriage Return on the end of the line
Febrian Nedsenda Rizky		February 9, 2019	   Add Splitting logic on ADDR
*********************************************************************************/
public class PC_Roche_TxtFileGeneratorHandler extends PC_Roche_TxtFileGeneratorBase{
    private String FinalString = '';

    /*********************************************************************************
Method Name    : generateFile
Description    : Generating txt file
Input Params   : List of Cycle Products 
Return Type    : N/A      
*********************************************************************************/ 
    public void generateFile(List<PC_Roche_Cycle_Product__c> listOfCycleProducts){
        Boolean isSandbox = [select IsSandbox from Organization limit 1].IsSandbox;
        listOfErrors = new List<GDrive_File_Upload_Error__c>();
        String googleAccessToken = '';
        String folderId = '';
        if(!isSandbox){
            googleAccessToken = accessToken();
            folderId = searchOrCreateFolder(googleAccessToken);
        }

        Blob file = prepareFile(listOfCycleProducts);

        Datetime dt = system.now();
        String day = dt.day() < 10 ? '0'+String.valueOf(dt.day()) : String.valueOf(dt.day());
        String month = dt.month() < 10 ? '0'+String.valueOf(dt.month()) : String.valueOf(dt.month());
        String year = String.valueOf(dt.year());
        String hour = dt.hour() < 10 ? '0'+String.valueOf(dt.hour()) : String.valueOf(dt.hour());
        String minute = dt.minute() < 10 ? '0'+String.valueOf(dt.minute()) : String.valueOf(dt.minute());
        String second = dt.second() < 10 ? '0'+String.valueOf(dt.second()) : String.valueOf(dt.second());
        //document name format (dd-mm-yyyy hh:mm:ss)
        String documentName = day+'-'+month+'-'+year+' '+hour+':'+minute+':'+second;
        if(!String.isEmpty(googleAccessToken) && !String.isEmpty(folderId)) {
            uploadFile(googleAccessToken, documentName, file, folderId);
        }
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
    private Blob prepareFile(List<PC_Roche_Cycle_Product__c> listOfCycleProducts){
        system.debug(listOfCycleProducts);
        List<PC_Roche_Cycle_Product__c> listOfUpdatedCycleProducts = new List<PC_Roche_Cycle_Product__c>();
        for(PC_Roche_Cycle_Product__c str : listOfCycleProducts){
            FinalString += ' '; //first dummy
            FinalString += forceLength( str.PC_Roche_Customer_Code__c, 10 );system.debug('col 1 : '+FinalString);
            FinalString = addDummy(FinalString);
            FinalString += forceLength( str.PC_Roche_Cycle__r.Name, 20 );system.debug('col 2 : '+FinalString);
            FinalString += forceLength( str.PC_Roche_Cycle__r.PC_Roche_FOC_Process_Date_Text__c,8 );system.debug('col 3 : '+FinalString);
            FinalString += forceLength( str.PC_Roche_Order_Type_1__c,4);system.debug('col 4 : '+FinalString);
            FinalString += forceLength( str.PC_Roche_Order_Type_2__c,3 );system.debug('col 5 : '+FinalString);
            FinalString += forceLength( str.PC_Roche_Delivery_Date_Text__c,8);system.debug('col 6 : '+FinalString);
            SplitWrapper SI1 = getSplittedString(createSI(str), 0, 120, 'SI');
            SplitWrapper SI2 = getSplittedString(createSI(str), SI1.nextCharacter, 28, 'SI'); 
            SplitWrapper SI3 = getSplittedString(createSI(str), SI1.nextCharacter+SI2.nextCharacter, 35, 'SI');
            SplitWrapper SI4 = getSplittedString(createSI(str), SI1.nextCharacter+SI2.nextCharacter+SI3.nextCharacter, 35, 'SI');
            SplitWrapper SI5 = getSplittedString(createSI(str), SI1.nextCharacter+SI2.nextCharacter+SI3.nextCharacter+SI4.nextCharacter, 35, 'SI');
            SplitWrapper SI6 = getSplittedString(createSI(str), SI1.nextCharacter+SI2.nextCharacter+SI3.nextCharacter+SI4.nextCharacter+SI5.nextCharacter, 30, 'SI');
            //if SI6 is empty, put dot mark
            String SI6Condition = SI6.splittedString.length()>0 ? SI6.splittedString : '.';
            SplitWrapper ADDR1 = getSplittedString(createAddr(str), 0, 35, 'ADDR');
            SplitWrapper ADDR2 = getSplittedString(createAddr(str), ADDR1.nextCharacter, 35, 'ADDR');
            SplitWrapper ADDR3 = getSplittedString(createAddr(str), ADDR1.nextCharacter+ADDR2.nextCharacter, 35, 'ADDR');
            FinalString += '\t'+SI1.splittedString;
            FinalString += '\t%%'+SI2.splittedString; //%%+28
            FinalString += forceLength(str.PC_Roche_Product_Code__c,18);system.debug('col 12 : '+FinalString);
            FinalString += forceLength(str.PC_Roche_SAP_Code__c,4);system.debug('col 13 : '+FinalString);
            FinalString = addDummy(FinalString);
            FinalString += forceLength(String.valueOf(str.PC_Roche_Quantity__c.setScale(0)),15); //col 14
            FinalString += forceLength(str.PC_Roche_UoM__c,3); //col 15
            FinalString += forceLength(str.PC_Roche_Warehouse__c,4); //col 16
            FinalString += forceLength(str.PC_Roche_WBS__c,24); //col 17
            FinalString += '\t'+SI3.splittedString; // col 18
            FinalString += '\t'+SI4.splittedString; // col 19
            FinalString += '\t'+SI5.splittedString; // col 20
            FinalString += '\t'+ADDR1.splittedString;
            FinalString += '\t'+ADDR2.splittedString;
            FinalString += '\t'+ADDR3.splittedString;
            FinalString += '\t'+ SI6Condition;
            FinalString = addDummy(FinalString);
            FinalString = addDummy(FinalString);
            FinalString = addDummy(FinalString);
            FinalString += '\r\n'; //new line for each cycle product //CRLF
        }
        Blob file = Blob.valueOf(FinalString);
        return file;
    }

    /*********************************************************************************
Method Name    : accessToken
Description    : Generate google access token through google service account
Input Params   : N/A
Return Type    : String
*********************************************************************************/
    private string accessToken(){
        System.debug('PC_Roche_TxtFileGeneratorHandler Generate Google Access Token...');
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
            System.debug('Completed PC_Roche_TxtFileGeneratorHandler Google Access Token Generation => '+token);
        }
        return token;
    }

    /*********************************************************************************
Method Name    : uploadFile
Description    : Upload file to google drive
Input Params   : Google Access Token, document name, file blob, parent Id
Return Type    : N/A      
*********************************************************************************/    
    private void uploadFile(String googleAccessToken, String documentName, Blob file, String parentId){
        system.debug('PC_Roche_TxtFileGeneratorHandler UPLOAD FILE METHOD...');
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
        System.debug('Completed PC_Roche_TxtFileGeneratorHandler UPLOAD FILE METHOD...');
    }
    
    /*********************************************************************************
Method Name    : searchOrCreateFolder
Description    : To search folder on root, if not exist it will create new folder
Input Params   : Google Access Token
Return Type    : String (folderId)     
*********************************************************************************/  
    private string searchOrCreateFolder(String googleAccessToken){
        system.debug('PC_Roche_TxtFileGeneratorHandler SEARCH FOLDER METHOD...');
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
        System.debug('Completed PC_Roche_TxtFileGeneratorHandler SEARCH OR CREATE FILE METHOD...');
        return 'Error';
    }

    
    /*********************************************************************************
Method Name    : sendFileByEmail
Description    : Send email to list of users
Input Params   : Document Name, File, List of (TO) recipients
Return Type    : N/A      
*********************************************************************************/
    private void sendFileByEmail(String documentName, Blob file, List<String> toAddresses){
        
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
        if(!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                    mail
            });
        }
    }

    
    //Wrapper class for request file to Google Drive API
    private class FileRequestClass {
        protected String name; //folder name
        protected String mimeType; //file type
        protected String teamDriveId; // team drive id
        protected List<String> parents; //parent folder id
        public FileRequestClass(String name, String mimeType, String teamDriveId, String parentId){
            this.name = name;
            this.mimeType = mimeType;
            this.teamDriveId = teamDriveId;
            this.parents = new List<String>{parentId};
                }
    }
    private class SplitWrapper{
        protected String splittedString; //SI or ADDR
        protected Integer nextCharacter;
        public SplitWrapper(String splittedString, Integer nextCharacter){
            this.splittedString = splittedString;
            this.nextCharacter = nextCharacter;
        }
    }

    /*********************************************************************************
Method Name    : getSplittedString
Description    : to split based on business need (chinese character will be count as 2 bytes, other 1 byte)
Input Params   : String, Integer, Integer, String
Return Type    : SplitWrapper
*********************************************************************************/
    private SplitWrapper getSplittedString(String text, Integer startCharacter, Integer maxByteLength, String splitType){
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
                else if(processedSI[i]=='$' && processedSI[i+1]=='$' && processedSI[i+1]!=null && splitType=='ADDR'){
                    if((byteLength+2)<=maxByteLength){
                        byteLength+=2;
                        i++;
                        characterCounter+=2;
                        splittedSI += '$$';
                    }else{
                        byteLength+=2;
                    }
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
}
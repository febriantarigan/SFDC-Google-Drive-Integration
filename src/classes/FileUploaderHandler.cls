/*********************************************************************************
Class Name      : FileUploaderHandler
Description     : Handler for DocumentFileUploaderBatch, Upload document to Team Drive
Created By      : FEBRIAN NEDSENDA RIZKY
Created Date    : November 15, 2018
Modification Log:
---------------------------------------------------------------------------------- 
Developer                   Date                   Description
-----------------------------------------------------------------------------------            
Febrian Nedsenda Rizky		November 15, 2018      Initial Version
*********************************************************************************/
public class FileUploaderHandler {    
    Private static List<GDrive_File_Upload_Error__c> listOfErrors;
    /*********************************************************************************
Method Name    : accessToken
Description    : Generate google access token through google service account
Input Params   : N/A
Return Type    : String      
*********************************************************************************/
    public static string accessToken(){  
        System.debug('DocumentFileUploaderHandler Generate Google Access Token...');
        String token = '';
        if (Test.isRunningTest()) {
            token = 'test-token-will-not-be-used';  
        } else { 
            
            //fetch service account credential on custom metadata type
            GDriveForSalesforce__mdt gDriveMDT = [SELECT Id, Service_Account_Id__c, Token_Endpoint__c, Scopes__c 
                                                  FROM GDriveForSalesforce__mdt WHERE DeveloperName ='TW_FOC_Application_Form' LIMIT 1];
            Auth.JWT jwt = new Auth.JWT();
            jwt.setAud( gDriveMDT.Token_Endpoint__c ); 
            jwt.setIss( gDriveMDT.Service_Account_Id__c );
            jwt.setAdditionalClaims( new Map<String, Object>{ 'scope' => gDriveMDT.Scopes__c } );
            
            // get JWS from certificate and key management api name (GDrive_Connector)
            Auth.JWS jws = new Auth.JWS( jwt, 'GDrive_Connector' ); 
            Auth.JWTBearerTokenExchange bearer = new Auth.JWTBearerTokenExchange( gDriveMDT.Token_Endpoint__c, jws );
            token = bearer.getAccessToken();
            System.debug('Completed FileUploaderHandler Google Access Token Generation => '+token);
        }
        return token;
    }
    
    /*********************************************************************************
Method Name    : uploadFile
Description    : Search & create folder then upload file to Google Drive
Input Params   : List of FileWrapper class
Return Type    : N/A      
*********************************************************************************/
    public static void uploadFile(List<FileWrapper> listFileWrapper){
        System.debug('FileUploaderHandler UPLOAD FILE METHOD...');
        listOfErrors = new List<GDrive_File_Upload_Error__c>();
        //get teamdrive id from custom metadata type
        GDriveForSalesforce__mdt gDriveMDT = [SELECT Id, Service_Account_Id__c, Token_Endpoint__c, Scopes__c, Team_Drive_Id__c 
                                              FROM GDriveForSalesforce__mdt WHERE DeveloperName ='TW_FOC_Application_Form' LIMIT 1];
        String teamDriveId = gDriveMDT.Team_Drive_Id__c;
        //get google access token
        String googleAccessToken = accessToken();
        //YYYYMM folder name creation
        String currentYearMonth = String.valueOf(system.today().year()) + String.valueOf(system.today().month());
        
        system.debug('listFileWrapper('+listFileWrapper.size()+') =>'+listFileWrapper);
        if(listFileWrapper.size()>0){
            for(FileWrapper fw : listFileWrapper){
                
                //Brand 1 and Brand 2 type are FREE
                if(fw.brandName1 !=null && fw.brandName1 !='' && fw.brandType1 =='Free' && fw.brandName2 !=null && fw.brandName2 !='' && fw.brandType2 =='Free'){
                    //Document preparation for brand 1
                    String documentName = fw.caseNumber+'_'+fw.cycleNumber +'_'+fw.documentName;
                    //Search parent folder
                    String brandFolder = searchOrCreateFolder(googleAccessToken, fw.brandName1, null, fw.cycleId, fw.cycleNumber);
                    if(fw.brand1Strength1 !=null && fw.brand1strength2 != null && fw.brand1Strength3!=null){
                        //brand 1 strength 1
                        String brand1Strength1Name = fw.brand1Strength1+fw.units;
                        String brand1Strength1Folder = searchOrCreateFolder(googleAccessToken, brand1Strength1Name, brandFolder, fw.cycleId, fw.cycleNumber);
                        String brand1Strength1MapFolder = searchOrCreateFolder(googleAccessToken, fw.mapId, brand1Strength1Folder, fw.cycleId, fw.cycleNumber);
                        String brand1Strength1YearMonthFolder = searchOrCreateFolder(googleAccessToken, currentYearMonth, brand1Strength1MapFolder, fw.cycleId, fw.cycleNumber);
                        FileRequestClass frc = new FileRequestClass(documentName, fw.contentType, teamDriveId, brand1Strength1YearMonthFolder);
                        createFile(googleAccessToken, new FileBulkWrapper(frc, fw.body, fw.cycleId, fw.cycleNumber), teamDriveId);
                        //brand 1 strength 2
                        String brand1Strength2Name = fw.brand1Strength2+fw.units;
                        String brand1Strength2Folder = searchOrCreateFolder(googleAccessToken, brand1Strength2Name, brandFolder, fw.cycleId, fw.cycleNumber);
                        String brand1Strength2MapFolder = searchOrCreateFolder(googleAccessToken, fw.mapId, brand1Strength2Folder, fw.cycleId, fw.cycleNumber);
                        String brand1Strength2YearMonthFolder = searchOrCreateFolder(googleAccessToken, currentYearMonth, brand1Strength2MapFolder, fw.cycleId, fw.cycleNumber);
                        FileRequestClass frc2 = new FileRequestClass(documentName, fw.contentType, teamDriveId, brand1Strength2YearMonthFolder);
                        createFile(googleAccessToken, new FileBulkWrapper(frc2, fw.body, fw.cycleId, fw.cycleNumber), teamDriveId);
                        //brand 1 strength 3
                        String brand1Strength3Name = fw.brand1Strength3+fw.units;
                        String brand1Strength3Folder = searchOrCreateFolder(googleAccessToken, brand1Strength3Name, brandFolder, fw.cycleId, fw.cycleNumber);
                        String brand1Strength3MapFolder = searchOrCreateFolder(googleAccessToken, fw.mapId, brand1Strength3Folder, fw.cycleId, fw.cycleNumber);
                        String brand1Strength3YearMonthFolder = searchOrCreateFolder(googleAccessToken, currentYearMonth, brand1Strength3MapFolder, fw.cycleId, fw.cycleNumber);
                        FileRequestClass frc3 = new FileRequestClass(documentName, fw.contentType, teamDriveId, brand1Strength3YearMonthFolder);
                        createFile(googleAccessToken, new FileBulkWrapper(frc3, fw.body, fw.cycleId, fw.cycleNumber), teamDriveId);
                    }
                    else if(fw.brand1Strength1 !=null && fw.brand1strength2 != null){
                        //brand 1 strength 1
                        String brand1Strength1Name = fw.brand1Strength1+fw.units;
                        String brand1Strength1Folder = searchOrCreateFolder(googleAccessToken, brand1Strength1Name, brandFolder, fw.cycleId, fw.cycleNumber);
                        String brand1Strength1MapFolder = searchOrCreateFolder(googleAccessToken, fw.mapId, brand1Strength1Folder, fw.cycleId, fw.cycleNumber);
                        String brand1Strength1YearMonthFolder = searchOrCreateFolder(googleAccessToken, currentYearMonth, brand1Strength1MapFolder, fw.cycleId, fw.cycleNumber);
                        FileRequestClass frc = new FileRequestClass(documentName, fw.contentType, teamDriveId, brand1Strength1YearMonthFolder);
                        createFile(googleAccessToken, new FileBulkWrapper(frc, fw.body, fw.cycleId, fw.cycleNumber), teamDriveId);
                        //brand 1 strength 2
                        String brand1Strength2Name = fw.brand1Strength2+fw.units;
                        String brand1Strength2Folder = searchOrCreateFolder(googleAccessToken, brand1Strength2Name, brandFolder, fw.cycleId, fw.cycleNumber);
                        String brand1Strength2MapFolder = searchOrCreateFolder(googleAccessToken, fw.mapId, brand1Strength2Folder, fw.cycleId, fw.cycleNumber);
                        String brand1Strength2YearMonthFolder = searchOrCreateFolder(googleAccessToken, currentYearMonth, brand1Strength2MapFolder, fw.cycleId, fw.cycleNumber);
                        FileRequestClass frc2 = new FileRequestClass(documentName, fw.contentType, teamDriveId, brand1Strength2YearMonthFolder);
                        createFile(googleAccessToken, new FileBulkWrapper(frc2, fw.body, fw.cycleId, fw.cycleNumber), teamDriveId);
                    }
                    else{
                        //brand 1 strength 1
                        String brand1Strength1Name = fw.brand1Strength1+fw.units;
                        String brand1Strength1Folder = searchOrCreateFolder(googleAccessToken, brand1Strength1Name, brandFolder, fw.cycleId, fw.cycleNumber);
                        String brand1Strength1MapFolder = searchOrCreateFolder(googleAccessToken, fw.mapId, brand1Strength1Folder, fw.cycleId, fw.cycleNumber);
                        String brand1Strength1YearMonthFolder = searchOrCreateFolder(googleAccessToken, currentYearMonth, brand1Strength1MapFolder, fw.cycleId, fw.cycleNumber);
                        FileRequestClass frc = new FileRequestClass(documentName, fw.contentType, teamDriveId, brand1Strength1YearMonthFolder);
                        createFile(googleAccessToken, new FileBulkWrapper(frc, fw.body, fw.cycleId, fw.cycleNumber), teamDriveId);
                    }
                    //Document preparation for brand 2
                    //Search parent folder
                    String brandFolder2 = searchOrCreateFolder(googleAccessToken, fw.brandName2, null, fw.cycleId, fw.cycleNumber);
                    if(fw.brand2Strength1 !=null && fw.brand2strength2 != null && fw.brand2Strength3!=null){
                        //brand 2 strength 1
                        String brand2Strength1Name = fw.brand2Strength1+fw.units;
                        String brand2Strength1Folder = searchOrCreateFolder(googleAccessToken, brand2Strength1Name, brandFolder2, fw.cycleId, fw.cycleNumber);
                        String brand2Strength1MapFolder = searchOrCreateFolder(googleAccessToken, fw.mapId, brand2Strength1Folder, fw.cycleId, fw.cycleNumber);
                        String brand2Strength1YearMonthFolder = searchOrCreateFolder(googleAccessToken, currentYearMonth, brand2Strength1MapFolder, fw.cycleId, fw.cycleNumber);
                        FileRequestClass frc = new FileRequestClass(documentName, fw.contentType, teamDriveId, brand2Strength1YearMonthFolder);
                        createFile(googleAccessToken, new FileBulkWrapper(frc, fw.body, fw.cycleId, fw.cycleNumber), teamDriveId);
                        //brand 2 strength 2
                        String brand2Strength2Name = fw.brand2Strength2+fw.units;
                        String brand2Strength2Folder = searchOrCreateFolder(googleAccessToken, brand2Strength2Name, brandFolder2, fw.cycleId, fw.cycleNumber);
                        String brand2Strength2MapFolder = searchOrCreateFolder(googleAccessToken, fw.mapId, brand2Strength2Folder, fw.cycleId, fw.cycleNumber);
                        String brand2Strength2YearMonthFolder = searchOrCreateFolder(googleAccessToken, currentYearMonth, brand2Strength2MapFolder, fw.cycleId, fw.cycleNumber);
                        FileRequestClass frc2 = new FileRequestClass(documentName, fw.contentType, teamDriveId, brand2Strength2YearMonthFolder);
                        createFile(googleAccessToken, new FileBulkWrapper(frc2, fw.body, fw.cycleId, fw.cycleNumber), teamDriveId);
                        //brand 2 strength 3
                        String brand2Strength3Name = fw.brand2Strength3+fw.units;
                        String brand2Strength3Folder = searchOrCreateFolder(googleAccessToken, brand2Strength3Name, brandFolder2, fw.cycleId, fw.cycleNumber);
                        String brand2Strength3MapFolder = searchOrCreateFolder(googleAccessToken, fw.mapId, brand2Strength3Folder, fw.cycleId, fw.cycleNumber);
                        String brand2Strength3YearMonthFolder = searchOrCreateFolder(googleAccessToken, currentYearMonth, brand2Strength3MapFolder, fw.cycleId, fw.cycleNumber);
                        FileRequestClass frc3 = new FileRequestClass(documentName, fw.contentType, teamDriveId, brand2Strength3YearMonthFolder);
                        createFile(googleAccessToken, new FileBulkWrapper(frc3, fw.body, fw.cycleId, fw.cycleNumber), teamDriveId);
                    }
                    else if(fw.brand2Strength1 !=null && fw.brand2strength2 != null){
                        //brand 2 strength 1
                        String brand2Strength1Name = fw.brand2Strength1+fw.units;
                        String brand2Strength1Folder = searchOrCreateFolder(googleAccessToken, brand2Strength1Name, brandFolder2, fw.cycleId, fw.cycleNumber);
                        String brand2Strength1MapFolder = searchOrCreateFolder(googleAccessToken, fw.mapId, brand2Strength1Folder, fw.cycleId, fw.cycleNumber);
                        String brand2Strength1YearMonthFolder = searchOrCreateFolder(googleAccessToken, currentYearMonth, brand2Strength1MapFolder, fw.cycleId, fw.cycleNumber);
                        FileRequestClass frc = new FileRequestClass(documentName, fw.contentType, teamDriveId, brand2Strength1YearMonthFolder);
                        createFile(googleAccessToken, new FileBulkWrapper(frc, fw.body, fw.cycleId, fw.cycleNumber), teamDriveId);
                        //brand 2 strength 2
                        String brand2Strength2Name = fw.brand2Strength2+fw.units;
                        String brand2Strength2Folder = searchOrCreateFolder(googleAccessToken, brand2Strength2Name, brandFolder2, fw.cycleId, fw.cycleNumber);
                        String brand2Strength2MapFolder = searchOrCreateFolder(googleAccessToken, fw.mapId, brand2Strength2Folder, fw.cycleId, fw.cycleNumber);
                        String brand2Strength2YearMonthFolder = searchOrCreateFolder(googleAccessToken, currentYearMonth, brand2Strength2MapFolder, fw.cycleId, fw.cycleNumber);
                        FileRequestClass frc2 = new FileRequestClass(documentName, fw.contentType, teamDriveId, brand2Strength2YearMonthFolder);
                        createFile(googleAccessToken, new FileBulkWrapper(frc2, fw.body, fw.cycleId, fw.cycleNumber), teamDriveId);
                    }
                    else{
                        //brand 2 strength 1
                        String brand2Strength1Name = fw.brand2Strength1+fw.units;
                        String brand2Strength1Folder = searchOrCreateFolder(googleAccessToken, brand2Strength1Name, brandFolder2, fw.cycleId, fw.cycleNumber);
                        String brand2Strength1MapFolder = searchOrCreateFolder(googleAccessToken, fw.mapId, brand2Strength1Folder, fw.cycleId, fw.cycleNumber);
                        String brand2Strength1YearMonthFolder = searchOrCreateFolder(googleAccessToken, currentYearMonth, brand2Strength1MapFolder, fw.cycleId, fw.cycleNumber);
                        FileRequestClass frc = new FileRequestClass(documentName, fw.contentType, teamDriveId, brand2Strength1YearMonthFolder);
                        createFile(googleAccessToken, new FileBulkWrapper(frc, fw.body, fw.cycleId, fw.cycleNumber), teamDriveId);
                    }
                }
                //Only Brand 1 type is FREE 
                else if(fw.brandName1 !=null && fw.brandName1 !='' && fw.brandType1 =='Free'){
                    //document preparation for brand 1
                    String documentName = fw.caseNumber+'_'+fw.cycleNumber +'_'+fw.documentName;
                    String brandFolder = searchOrCreateFolder(googleAccessToken, fw.brandName1, null, fw.cycleId, fw.cycleNumber);
                    if(fw.brand1Strength1 !=null && fw.brand1strength2 != null && fw.brand1Strength3!=null){
                        //brand 1 strength 1
                        String brand1Strength1Name = fw.brand1Strength1+fw.units;
                        String brand1Strength1Folder = searchOrCreateFolder(googleAccessToken, brand1Strength1Name, brandFolder, fw.cycleId, fw.cycleNumber);
                        String brand1Strength1MapFolder = searchOrCreateFolder(googleAccessToken, fw.mapId, brand1Strength1Folder, fw.cycleId, fw.cycleNumber);
                        String brand1Strength1YearMonthFolder = searchOrCreateFolder(googleAccessToken, currentYearMonth, brand1Strength1MapFolder, fw.cycleId, fw.cycleNumber);
                        FileRequestClass frc = new FileRequestClass(documentName, fw.contentType, teamDriveId, brand1Strength1YearMonthFolder);
                        createFile(googleAccessToken, new FileBulkWrapper(frc, fw.body, fw.cycleId, fw.cycleNumber), teamDriveId);
                        //brand 1 strength 2
                        String brand1Strength2Name = fw.brand1Strength2+fw.units;
                        String brand1Strength2Folder = searchOrCreateFolder(googleAccessToken, brand1Strength2Name, brandFolder, fw.cycleId, fw.cycleNumber);
                        String brand1Strength2MapFolder = searchOrCreateFolder(googleAccessToken, fw.mapId, brand1Strength2Folder, fw.cycleId, fw.cycleNumber);
                        String brand1Strength2YearMonthFolder = searchOrCreateFolder(googleAccessToken, currentYearMonth, brand1Strength2MapFolder, fw.cycleId, fw.cycleNumber);
                        FileRequestClass frc2 = new FileRequestClass(documentName, fw.contentType, teamDriveId, brand1Strength2YearMonthFolder);
                        createFile(googleAccessToken, new FileBulkWrapper(frc2, fw.body, fw.cycleId, fw.cycleNumber), teamDriveId);
                        //brand 1 strength 3
                        String brand1Strength3Name = fw.brand1Strength3+fw.units;
                        String brand1Strength3Folder = searchOrCreateFolder(googleAccessToken, brand1Strength3Name, brandFolder, fw.cycleId, fw.cycleNumber);
                        String brand1Strength3MapFolder = searchOrCreateFolder(googleAccessToken, fw.mapId, brand1Strength3Folder, fw.cycleId, fw.cycleNumber);
                        String brand1Strength3YearMonthFolder = searchOrCreateFolder(googleAccessToken, currentYearMonth, brand1Strength3MapFolder, fw.cycleId, fw.cycleNumber);
                        FileRequestClass frc3 = new FileRequestClass(documentName, fw.contentType, teamDriveId, brand1Strength3YearMonthFolder);
                        createFile(googleAccessToken, new FileBulkWrapper(frc3, fw.body, fw.cycleId, fw.cycleNumber), teamDriveId);
                    }
                    else if(fw.brand1Strength1 !=null && fw.brand1strength2 != null){
                        //brand 1 strength 1
                        String brand1Strength1Name = fw.brand1Strength1+fw.units;
                        String brand1Strength1Folder = searchOrCreateFolder(googleAccessToken, brand1Strength1Name, brandFolder, fw.cycleId, fw.cycleNumber);
                        String brand1Strength1MapFolder = searchOrCreateFolder(googleAccessToken, fw.mapId, brand1Strength1Folder, fw.cycleId, fw.cycleNumber);
                        String brand1Strength1YearMonthFolder = searchOrCreateFolder(googleAccessToken, currentYearMonth, brand1Strength1MapFolder, fw.cycleId, fw.cycleNumber);
                        FileRequestClass frc = new FileRequestClass(documentName, fw.contentType, teamDriveId, brand1Strength1YearMonthFolder);
                        createFile(googleAccessToken, new FileBulkWrapper(frc, fw.body, fw.cycleId, fw.cycleNumber), teamDriveId);
                        //brand 1 strength 2
                        String brand1Strength2Name = fw.brand1Strength2+fw.units;
                        String brand1Strength2Folder = searchOrCreateFolder(googleAccessToken, brand1Strength2Name, brandFolder, fw.cycleId, fw.cycleNumber);
                        String brand1Strength2MapFolder = searchOrCreateFolder(googleAccessToken, fw.mapId, brand1Strength2Folder, fw.cycleId, fw.cycleNumber);
                        String brand1Strength2YearMonthFolder = searchOrCreateFolder(googleAccessToken, currentYearMonth, brand1Strength2MapFolder, fw.cycleId, fw.cycleNumber);
                        FileRequestClass frc2 = new FileRequestClass(documentName, fw.contentType, teamDriveId, brand1Strength2YearMonthFolder);
                        createFile(googleAccessToken, new FileBulkWrapper(frc2, fw.body, fw.cycleId, fw.cycleNumber), teamDriveId);
                    }
                    else{
                        //brand 1 strength 1
                        String brand1Strength1Name = fw.brand1Strength1+fw.units;
                        String brand1Strength1Folder = searchOrCreateFolder(googleAccessToken, brand1Strength1Name, brandFolder, fw.cycleId, fw.cycleNumber);
                        String brand1Strength1MapFolder = searchOrCreateFolder(googleAccessToken, fw.mapId, brand1Strength1Folder, fw.cycleId, fw.cycleNumber);
                        String brand1Strength1YearMonthFolder = searchOrCreateFolder(googleAccessToken, currentYearMonth, brand1Strength1MapFolder, fw.cycleId, fw.cycleNumber);
                        FileRequestClass frc = new FileRequestClass(documentName, fw.contentType, teamDriveId, brand1Strength1YearMonthFolder);
                        createFile(googleAccessToken, new FileBulkWrapper(frc, fw.body, fw.cycleId, fw.cycleNumber), teamDriveId);
                    }
                }
                //Only Brand 2 type is FREE
                else if(fw.brandName2 !=null && fw.brandName2 !='' && fw.brandType2 =='Free'){
                    //document preparation for brand 2
                    String documentName = fw.caseNumber+'_'+fw.cycleNumber +'_'+fw.documentName;
                    String brandFolder = searchOrCreateFolder(googleAccessToken, fw.brandName2, null, fw.cycleId, fw.cycleNumber);
                    if(fw.brand2Strength1 !=null && fw.brand2strength2 != null && fw.brand2Strength3!=null){
                        //brand 2 strength 1
                        String brand2Strength1Name = fw.brand2Strength1+fw.units;
                        String brand2Strength1Folder = searchOrCreateFolder(googleAccessToken, brand2Strength1Name, brandFolder, fw.cycleId, fw.cycleNumber);
                        String brand2Strength1MapFolder = searchOrCreateFolder(googleAccessToken, fw.mapId, brand2Strength1Folder, fw.cycleId, fw.cycleNumber);
                        String brand2Strength1YearMonthFolder = searchOrCreateFolder(googleAccessToken, currentYearMonth, brand2Strength1MapFolder, fw.cycleId, fw.cycleNumber);
                        FileRequestClass frc = new FileRequestClass(documentName, fw.contentType, teamDriveId, brand2Strength1YearMonthFolder);
                        createFile(googleAccessToken, new FileBulkWrapper(frc, fw.body, fw.cycleId, fw.cycleNumber), teamDriveId);
                        //brand 2 strength 2
                        String brand2Strength2Name = fw.brand2Strength2+fw.units;
                        String brand2Strength2Folder = searchOrCreateFolder(googleAccessToken, brand2Strength2Name, brandFolder, fw.cycleId, fw.cycleNumber);
                        String brand2Strength2MapFolder = searchOrCreateFolder(googleAccessToken, fw.mapId, brand2Strength2Folder, fw.cycleId, fw.cycleNumber);
                        String brand2Strength2YearMonthFolder = searchOrCreateFolder(googleAccessToken, currentYearMonth, brand2Strength2MapFolder, fw.cycleId, fw.cycleNumber);
                        FileRequestClass frc2 = new FileRequestClass(documentName, fw.contentType, teamDriveId, brand2Strength2YearMonthFolder);
                        createFile(googleAccessToken, new FileBulkWrapper(frc2, fw.body, fw.cycleId, fw.cycleNumber), teamDriveId);
                        //brand 2 strength 3
                        String brand2Strength3Name = fw.brand2Strength3+fw.units;
                        String brand2Strength3Folder = searchOrCreateFolder(googleAccessToken, brand2Strength3Name, brandFolder, fw.cycleId, fw.cycleNumber);
                        String brand2Strength3MapFolder = searchOrCreateFolder(googleAccessToken, fw.mapId, brand2Strength3Folder, fw.cycleId, fw.cycleNumber);
                        String brand2Strength3YearMonthFolder = searchOrCreateFolder(googleAccessToken, currentYearMonth, brand2Strength3MapFolder, fw.cycleId, fw.cycleNumber);
                        FileRequestClass frc3 = new FileRequestClass(documentName, fw.contentType, teamDriveId, brand2Strength3YearMonthFolder);
                        createFile(googleAccessToken, new FileBulkWrapper(frc3, fw.body, fw.cycleId, fw.cycleNumber), teamDriveId);
                    }
                    else if(fw.brand2Strength1 !=null && fw.brand2strength2 != null){
                        //brand 2 strength 1
                        String brand2Strength1Name = fw.brand2Strength1+fw.units;
                        String brand2Strength1Folder = searchOrCreateFolder(googleAccessToken, brand2Strength1Name, brandFolder, fw.cycleId, fw.cycleNumber);
                        String brand2Strength1MapFolder = searchOrCreateFolder(googleAccessToken, fw.mapId, brand2Strength1Folder, fw.cycleId, fw.cycleNumber);
                        String brand2Strength1YearMonthFolder = searchOrCreateFolder(googleAccessToken, currentYearMonth, brand2Strength1MapFolder, fw.cycleId, fw.cycleNumber);
                        FileRequestClass frc = new FileRequestClass(documentName, fw.contentType, teamDriveId, brand2Strength1YearMonthFolder);
                        createFile(googleAccessToken, new FileBulkWrapper(frc, fw.body, fw.cycleId, fw.cycleNumber), teamDriveId);
                        //brand 2 strength 2
                        String brand2Strength2Name = fw.brand2Strength2+fw.units;
                        String brand2Strength2Folder = searchOrCreateFolder(googleAccessToken, brand2Strength2Name, brandFolder, fw.cycleId, fw.cycleNumber);
                        String brand2Strength2MapFolder = searchOrCreateFolder(googleAccessToken, fw.mapId, brand2Strength2Folder, fw.cycleId, fw.cycleNumber);
                        String brand2Strength2YearMonthFolder = searchOrCreateFolder(googleAccessToken, currentYearMonth, brand2Strength2MapFolder, fw.cycleId, fw.cycleNumber);
                        FileRequestClass frc2 = new FileRequestClass(documentName, fw.contentType, teamDriveId, brand2Strength2YearMonthFolder);
                        createFile(googleAccessToken, new FileBulkWrapper(frc2, fw.body, fw.cycleId, fw.cycleNumber), teamDriveId);
                    }
                    else{
                        //brand 2 strength 1
                        String brand2Strength1Name = fw.brand2Strength1+fw.units;
                        String brand2Strength1Folder = searchOrCreateFolder(googleAccessToken, brand2Strength1Name, brandFolder, fw.cycleId, fw.cycleNumber);
                        String brand2Strength1MapFolder = searchOrCreateFolder(googleAccessToken, fw.mapId, brand2Strength1Folder, fw.cycleId, fw.cycleNumber);
                        String brand2Strength1YearMonthFolder = searchOrCreateFolder(googleAccessToken, currentYearMonth, brand2Strength1MapFolder, fw.cycleId, fw.cycleNumber);
                        FileRequestClass frc = new FileRequestClass(documentName, fw.contentType, teamDriveId, brand2Strength1YearMonthFolder);
                        createFile(googleAccessToken, new FileBulkWrapper(frc, fw.body, fw.cycleId, fw.cycleNumber), teamDriveId);
                    }
                }
                
                else{
                    system.debug('enter else condition');
                    createErrorLog(fw.cycleId, fw.cycleNumber, 'uploadFile', 'Too Many Callout: 101');
                }
            }
            system.debug('SIZE ERRORS => '+listOfErrors.size());
            if(listOfErrors.size()>0)
                insert listOfErrors;
        }
        System.debug('Completed FileUploaderHandler UPLOAD FILE METHOD...');
    }    
    
    /*********************************************************************************
Method Name    : createFile
Description    : Upload file to google drive
Input Params   : Google Access Token, List of FileWrapper, Team Drive Id
Return Type    : N/A      
*********************************************************************************/    
    private static void createFile(String googleAccessToken, FileBulkWrapper fbw, String teamDriveId){
        system.debug('FileUploaderHandler CREATE FILE METHOD...');
        //boundary that required for uploading file to google drive
        String boundary = 'END_OF_PART';
        String delimiter = '\r\n--' + boundary +'\r\n';
        String close_delim = '\r\n--' + boundary + '--';
        
        FileRequestClass frc = fbw.frc;
        String bodyEncoded = EncodingUtil.base64Encode(fbw.body); //encode blob to string
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
        system.debug('CREATE FILE STATUS => '+createFileResponse.getStatusCode());
        if(createFileResponse.getStatusCode() != 200)
            createErrorLog(fbw.cycleId, fbw.cycleNumber, 'createFile', createFileResponse.getBody());
        
        System.debug('Completed FileUploaderHandler CREATE FILE METHOD...');
    }
    
    /*********************************************************************************
Method Name    : searchOrCreateFolder
Description    : To search folder, if not exist it will create new folder
Input Params   : Google Access Token, Folder Name, Parent Id
Return Type    : String (folderId)     
*********************************************************************************/  
    private static string searchOrCreateFolder(String googleAccessToken, String folderName, String parentId, String cycleId, String cycleNumber){
        system.debug('FileUploaderHandler SEARCH FOLDER METHOD...');
        system.debug('SEARCH FOLDER METHOD => '+folderName);
        GDriveForSalesforce__mdt gDriveMDT = [SELECT Id, Service_Account_Id__c, Token_Endpoint__c, Scopes__c, Team_Drive_Id__c FROM GDriveForSalesforce__mdt WHERE DeveloperName ='TW_FOC_Application_Form' LIMIT 1];
        String teamDriveId = gDriveMDT.Team_Drive_Id__c;
        
        //Set endpoint query parameter
        String query ='';
        if(parentId != null && parentId !='')
            query = 'mimeType = \'application/vnd.google-apps.folder\' and trashed = false and name = \''+folderName+'\' and \''+parentId+'\' in parents';
        else
            query = 'mimeType = \'application/vnd.google-apps.folder\' and trashed = false and name = \''+folderName+'\'';
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
            FileRequestClass fc = new FileRequestClass();
            String messageBody ='';
            if(parentId != null && parentId !='')
                fc.parents = new list<String>{parentId};
                    else
                    fc.parents = new list<String>{teamDriveId};        	
                        fc.mimeType='application/vnd.google-apps.folder';
            fc.name = folderName;
            fc.teamDriveId = teamDriveId;
            messageBody = Json.serialize(fc);
            
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
                createErrorLog(cycleId, cycleNumber, 'searchOrCreateFolder(create)',createFolderResponse.getBody());
            System.debug('Completed CREATE FILE METHOD...');
        }
        else
            createErrorLog(cycleId, cycleNumber, 'searchOrCreateFolder(search)', searchFolderResponse.getBody());
        System.debug('Completed FileUploaderHandler SEARCH OR CREATE FILE METHOD...');
        return 'Error';
    }
    
    private static void createErrorLog(String cycleId, String cycleNumber, String methodName, String errorMessage){
        GDrive_File_Upload_Error__c log = new GDrive_File_Upload_Error__c();
        log.Cycle_Id__c = cycleId;
        log.Cycle_Number__c = cycleNumber;
        log.Error_Message__c = errorMessage;
        log.Error_Datetime__c = system.now();
        log.Method_Name__c = methodName;
        log.Class_Name__c = 'FileUploaderHandler';
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
        public FileRequestClass(){}
    }
    //Wrapper class for bulk create file
    private class FileBulkWrapper{
        public FileRequestClass frc{get;set;}
        public Blob body { get; set;}
        public String cycleId {get;set;}
        public String cycleNumber {get;set;}
        public FileBulkWrapper(FileRequestClass frc, Blob body, String cycleId, String cycleNumber){
            this.frc = frc;
            this.body = body;
            this.cycleId = cycleId;
            this.cycleNumber = cycleNumber;
        }
    }
    //Wrapper class to get all necessary fields from batch
    public class FileWrapper{
        public Blob body { get; set;}
        public String contentType {get;set;}
        public String brandName1 { get; set;}
        public String brandType1 {get;set;}
        public String brand1Strength1 {get;set;}
        public String brand1Strength2 {get;set;}
        public String brand1Strength3 {get;set;}
        public String brandName2 { get; set;}
        public String brandType2 {get;set;}
        public String brand2Strength1 {get;set;}
        public String brand2Strength2 {get;set;}
        public String brand2Strength3 {get;set;}
        public String mapId { get; set;}
        public String caseNumber { get; set;}
        public String documentName { get; set;}
        public String cycleNumber {get;set;}
        public String cycleId {get;set;}
        public String units {get;set;}
        
        public FileWrapper(String documentName, Blob body, String contentType, String caseNumber, String cycleNumber, String cycleId, String brandName1, String brandType1, Decimal brand1Strength1, Decimal brand1Strength2, Decimal brand1Strength3, String brandName2, String brandType2, Decimal brand2Strength1, Decimal brand2Strength2, Decimal brand2Strength3, String units, String mapId){
            this.body = body;
            this.contentType = contentType;
            this.brandName1 = brandName1;
            this.brandType1 = brandType1;
            this.brandName2 = brandName2;
            this.brandType2 = brandType2;
            this.brand1Strength1 = String.valueOf(brand1Strength1);
            this.brand1Strength2 = String.valueOf(brand1Strength2);
            this.brand1Strength3 = String.valueOf(brand1Strength3);
            this.brand2Strength1 = String.valueOf(brand2Strength1);
            this.brand2Strength2 = String.valueOf(brand2Strength2);
            this.brand2Strength3 = String.valueOf(brand2Strength3);
            this.units = units;
            this.mapId = mapId;
            this.caseNumber = caseNumber;
            this.documentName = documentName;
            this.cycleNumber = cycleNumber;
            this.cycleId = cycleId;
        }
    }
}
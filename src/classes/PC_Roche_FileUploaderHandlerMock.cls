@isTest
global class PC_Roche_FileUploaderHandlerMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {   
         HttpResponse res = new HttpResponse(); 
        res.setHeader('Content-Type', 'application/json');
        //request for uploading file
        if(req.getEndpoint().startsWith('https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart&supportsTeamDrives=true'))
            res.setBody('{"name":"test file","id":"10D7OsUFVariT5Ghe3CYV7akLjLZa00PY","mimeType":"application/pdf",parents":["1KGRBDAbYvcHZoKz9H76IRA8dy2QblhFu"],"teamDriveId":"0AGj2ssL2WNiVUk9PVA"}');
        //request for searching folder
        else if(req.getEndpoint().startsWith('https://www.googleapis.com/drive/v3/files?corpora=teamDrive&includeTeamDriveItems=true&supportsTeamDrives=true&teamDriveId='))
            res.setBody('{"name":"test folder","i33":"10D7OsUFVariT5Ghe3CYV7akLjLZa00PY","teamDriveId":"0AGj2ssL2WNiVUk9PVA"}');
        //request for creating folder
        else if(req.getEndpoint().startsWith('https://www.googleapis.com/drive/v3/files?supportsTeamDrives=true'))
            res.setBody('{"name":"test folder","id":"1KGRBDAbYvcHZoKz9H76IRA8dy2QblhFu","teamDriveId":"0AGj2ssL2WNiVUk9PVA"}');            
        res.setStatusCode(200);
        return res; 
        
       //   Implement this interface method

		/* HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"name":"test file","id":"10D7OsUFVariT5Ghe3CYV7akLjLZa00PY","mimeType":"application/pdf",parents":["1KGRBDAbYvcHZoKz9H76IRA8dy2QblhFu"],"teamDriveId":"0AGj2ssL2WNiVUk9PVA"}');
        response.setStatusCode(200);
        return response; */

    }
}
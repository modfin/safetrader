var CLIENT_ID = '663745837623-k2k1ndjdrorpqnltsk3q57558p8gi6vl.apps.googleusercontent.com';
var API_KEY = 'AIzaSyD3oWM-Jz6RlcTbgJKaBjHYgweBM_dtwWg';
var DISCOVERY_DOCS = ["https://sheets.googleapis.com/$discovery/rest?version=v4"];
var SCOPES = 'https://www.googleapis.com/auth/spreadsheets.readonly';

let gapiLoaded = new Promise ((resolve, reject) => {
    const initClient = () => {
        gapi.client.init({
            apiKey: API_KEY,
            clientId: CLIENT_ID,
            discoveryDocs: DISCOVERY_DOCS,
            scope: SCOPES
        })
        .then(() => resolve(gapi))
        .catch(e => reject(e));
    }

    gapi.load('client:auth2', initClient);
});

let app = Elm.Main.init({ node: document.getElementById('elm') });

var DISCOVERY_DOCS = ["https://sheets.googleapis.com/$discovery/rest?version=v4"];
var SCOPES = 'https://www.googleapis.com/auth/spreadsheets.readonly';

chrome.extension.getBackgroundPage().gapiLoaded
    .then(gapi => {
        function updateSigninStatus(auth) {
            if (auth.isSignedIn.get()) {
                const currentUser = auth.currentUser.get();
                const userId = currentUser.getId();
                const basicProfile = currentUser.getBasicProfile();
                const fullName = basicProfile.getName();
                const email = basicProfile.getEmail();
                const accessToken = gapi.auth.getToken().access_token;
                app.ports.authStateChanged.send({
                    userId: userId,
                    fullName: fullName,
                    email: email,
                    accessToken: accessToken
                });
            }
            else {
              app.ports.authStateChanged.send({});
            }
        }

        app.ports.signIn.subscribe(() => {
            gapi.auth2.getAuthInstance().signIn();
        })

        app.ports.signOut.subscribe(() => {
            gapi.auth2.getAuthInstance().signOut();
        })

        gapi.auth2.getAuthInstance().isSignedIn.listen(() => {
            updateSigninStatus(gapi.auth2.getAuthInstance())
        });
        updateSigninStatus(gapi.auth2.getAuthInstance());
    })
    .catch(e => console.error(e));

//    chrome.storage.sync.set({'foo': 'hello', 'bar': 'hi'}, function() {
//      console.log('Settings saved');
//    });

    // Read it using the storage API
//    chrome.storage.sync.get(['foo', 'bar'], function(items) {
//      message('Settings retrieved', items);
//    });

app.ports.sheetIdStorageUpdated.send("testId")
app.ports.sheetRangeStorageUpdated.send("testRange")

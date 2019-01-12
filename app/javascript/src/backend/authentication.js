import auth0 from "auth0-js";
import Vue from "vue/dist/vue.esm";
import Cookies from "js-cookie";
import { AUTH_CONFIG } from "./auth0-variables";

// exchange the object with your own from the setup step above.
let webAuth = new auth0.WebAuth({
  domain: AUTH_CONFIG.domain,
  clientID: AUTH_CONFIG.clientId,
  // make sure this line is contains the port: 8080
  redirectUri: AUTH_CONFIG.callbackUrl,
  // we will use the api/v2/ to access the user information as payload
  audience: "https://" + AUTH_CONFIG.domain + "/api/v2/",
  responseType: "token id_token",
  scope: "openid profile email" // define the scopes you want to use
});

// TODO we should store in secure cookies, not localstorage
let cookieOptions = {};

if (process.env.NODE_ENV != "development") {
  cookieOptions = {
    domain: "eventacc.es",
    secure: true
  };
}

let auth = new Vue({
  computed: {
    token: {
      get: function() {
        return Cookies.get("regToken");
      },
      set: function(id_token) {
        Cookies.set("regToken", id_token, cookieOptions);
      }
    },
    accessToken: {
      get: function() {
        let regAccessToken = Cookies.get("regAccessToken");
        return regAccessToken;
      },
      set: function(accessToken) {
        // localStorage.setItem("access_token", accessToken);
        Cookies.set("regAccessToken", accessToken, cookieOptions);
      }
    },
    expiresAt: {
      get: function() {
        return Cookies.get("regExpiresAt");
      },
      set: function(expiresIn) {
        let expiresAt = JSON.stringify(expiresIn * 1000 + new Date().getTime());
        Cookies.set("regExpiresAt", expiresAt, cookieOptions);
      }
    },
    user: {
      get: function() {
        let result = Cookies.get("regUser");
        if (result == undefined) return {};
        return JSON.parse(result);
      },
      set: function(user) {
        Cookies.set("regUser", JSON.stringify(user), cookieOptions);
      }
    },
    //TODO improve this
    roles: {
      get: function() {
        let result = Cookies.get("regRoles");
        if (result == null || result == undefined || result == "undefined") {
          // console.log("No roles from cookies");
          return JSON.stringify({
            role: "Default",
            super_admin: false,
            admin: false,
            team_id: "default"
          });
        }
        // console.log("here is roles from cookies " + result);
        return JSON.parse(result);
      },
      set: function(serverRoles) {
        let roles = JSON.stringify(serverRoles);
        Cookies.set("regRoles", roles, cookieOptions);
      }
    }
  },
  methods: {
    login() {
      webAuth.authorize();
    },
    logout() {
      return new Promise((resolve, reject) => {
        this.removeAuthCookies();
        //TODO: fix this localhost link, put in a env var
        webAuth.logout({
          returnTo:  AUTH_CONFIG.loginUrl,
          clientID: AUTH_CONFIG.clientId
        });
      });
    },
    logoutToSyncAccount() {
      return new Promise((resolve, reject) => {
        this.removeAuthCookies();
        //TODO: fix this localhost link, put in a env var
        webAuth.logout({
          returnTo: AUTH_CONFIG.syncAccountUrl,
          clientID: AUTH_CONFIG.clientId
        });
      });
    },
    isAuthenticated() {
      return new Date().getTime() < this.expiresAt;
    },
    // gets roles and team from server
    // NOTE: just use this first api call to make sure 
    //  + token is valid
    //  + user is existed in Register, otherwise throw exception
    fetchRoles() {
      return this.$http
        .post("/account/roles")
        .then(response => {
          return response.data.data.roles;
        })
        .catch(xhr => {
          throw xhr.response.data; // contain error info
        });
    },
    setAuthCookies (authResult) {
      this.expiresAt = authResult.expiresIn;
      this.accessToken = authResult.accessToken;
      this.token = authResult.idToken;
      this.user = authResult.idTokenPayload;
    },
    removeAuthCookies () {
      Cookies.remove("regRoles");
      Cookies.remove("regUser");
      Cookies.remove("regExpiresAt");
      Cookies.remove("regAccessToken");
      Cookies.remove("regToken");
    },
    handleAuthentication() {
      return new Promise((resolve, reject) => {
        webAuth.parseHash((err, authResult) => {
          if (authResult && authResult.accessToken && authResult.idToken) {
            this.setAuthCookies(authResult);
            // this.authNotifier.emit('authChange', { authenticated: true });
            //TODO how do we get roles and permissions?
            // this.roles = this.fetchRoles();
            const loadingComponent = this.$loading.open("We are syncing your account ...");
            this.fetchRoles().then(roles => {
              loadingComponent.close();
              this.roles = roles;
              resolve(); //  TODO: can return data here
            })
            .catch(error => {
              loadingComponent.close();
              reject(error);
            });
          } else if (err) {
            this.logout();
            reject(err);
          }
        });
      });
    }
  }
});

export default {
  install: function(Vue) {
    Vue.prototype.$auth = auth;
  }
};

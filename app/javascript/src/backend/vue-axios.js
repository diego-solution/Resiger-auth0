// Configure axios
import Vue from "vue/dist/vue.esm";
import axios from "axios";
import VueAxios from "vue-axios";
import { shim } from "promise.prototype.finally";
shim();
import Cookies from "js-cookie";

const API_BASE_URL = "/api/v1";
let token = document.getElementsByName("csrf-token")[0].getAttribute("content");

const defaultOptions = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    "Content-Type": "application/json",
    "Accept-Version": "v1",
    "X-CSRF-Token": token
  }
});

// Set the AUTH token for any request
defaultOptions.interceptors.request.use(
  function(config) {
    // let authToken = Vue.prototype.$auth.accessToken;
    let authToken = Cookies.get("regAccessToken");

    config.headers.Authorization = authToken ? `Bearer ${authToken}` : "";
    if (authToken == undefined) {
      // console.log("authToken is not set");
    }
    return config;
  },
  function(error) {
    return Promise.reject(error);
  }
);

defaultOptions.interceptors.response.use(
  function(response) {
    // we could use this to always show a generic loader
    return response;
  },
  function(error) {
    // we could use this to auto refresh token
    if (error.response.status === 401) {
      // TODO logout person and show err msg
      // console.log("if its a 401 so we should logout this person");
      Vue.prototype.$auth.logout(
        "For security reasons, we've signed you out. Please enter your details again"
      );
    }
    return Promise.reject(error);
  }
);

Vue.use(VueAxios, defaultOptions);
export default defaultOptions;

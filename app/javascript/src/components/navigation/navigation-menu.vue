<template>
  <div class="container top-menu">
    <div class="columns o-menu" v-show="userRoles">
      <div class="column is-12">
        <div class="o-menu__logo">
          <b-dropdown class="m-form__type" hoverable>
            <button class="button is-big is-link" slot="trigger">
              <span>Register</span>
              <img class="arrow" src="~images/icons/arrow-drop-white.svg" alt="choose workplace">
            </button>
            <b-dropdown-item has-link>
              <a href="https://www.eventfuel.io/home">Create</a>
            </b-dropdown-item>
          </b-dropdown>
        </div>

        <a class="m-mobile__menu" v-on:click="mobileMenu = !mobileMenu" v-bind:class="{ open: mobileMenu }">
          <span></span>
          <span></span>
          <span></span>
          <span></span>
        </a>

        <div class="o-menu__pages" v-bind:class="{ mobile: mobileMenu }">
          <ul class="o-menu__pages-pages">
            <li><router-link to="/manage/events">Events</router-link></li>
            <li><router-link to="/manage/forms">Forms</router-link></li>
            <li><router-link to="/manage/layouts">Layouts</router-link></li>
            <li><router-link to="/manage/groups">Groups</router-link></li>
            <li><router-link to="/manage/translations">Translations</router-link></li>
            <li v-if="userRoles.super_admin">
              <router-link to="/manage/teams">Team</router-link>
            </li>
            <li v-if="userRoles.admin">
              <router-link to="/manage/users">Users</router-link>
            </li>
          </ul>
        </div>
        <div class="o-menu__account">
          <b-dropdown class="m-form__type" position="is-bottom-left" hoverable>
            <button class="button a-button-image account" slot="trigger">
              <template><img src="~images/icons/feedback.svg" alt="feedback"></template>
            </button>
            <b-dropdown-item has-link>
              <a href="https://help.eventfuel.io/" target="_blank">Help <span class="icon is-small"><i class="mdi mdi-arrow-right"></i></span></a>
            </b-dropdown-item>
            <!-- <b-dropdown-item has-link><router-link to="">Feedback</router-link></b-dropdown-item> -->
          </b-dropdown>

          <b-dropdown class="m-form__type" position="is-bottom-left" hoverable>
            <button class="button a-button-image account" slot="trigger">
              <template><img src="~images/icons/account.svg" alt="account options"></template>
            </button>
            <b-dropdown-item class="info" custom v-if="userRoles">
              <p>{{ $auth.user.name }}</p>
              <p class="small">{{ userRoles.role }} | {{ getTeamName(userRoles.team_id) }} </p>
            </b-dropdown-item>

            <template v-if="optionsTeam.length>0">
              <hr class="dropdown-divider">
              <b-dropdown-item custom>
                <b>Teams</b>
              </b-dropdown-item>
              <b-dropdown-item v-for="option in optionsTeam"
                              :value="option.id"
                              :key="option.id"
                              has-link>
                <a href="#" @click.prevent="onChangeContext(option)"> {{ option.name }}</a>
              </b-dropdown-item>
            </template>

            <hr class="dropdown-divider">
            <b-dropdown-item has-link><router-link to="/manage/account">Account</router-link></b-dropdown-item>
            <b-dropdown-item has-link><router-link to="/logout">Log out</router-link></b-dropdown-item>
          </b-dropdown>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  import { messages } from '../../mixins/messages'

  export default {
    data(){
      return {
        mobileMenu: false,
        currentTeam: null,
        teamName: "",
        optionsTeam: []
      }
    },
    created (){
      this.fetchData()
    },
    mixins: [messages],
    computed: {
      // a computed getter
      userRoles: function () {
        // `this` points to the vm instance
        return this.$auth.roles;
      }
    },
    methods: {
      // load data
      fetchData() {
        this.$http.get('/teams').then((response) => {
          this.optionsTeam = response.data.data
        }, (error) => {
          this.optionsTeam = []
          this.displayErrorMessage(error);
        })
      },
      onChangeContext(team_choosen){
        // this.$auth.changeCurrentTeam(team_choosen.id);
        const loadingComponent = this.$loading.open();

        this.$http
          .post("/account/change_team", {
            email: this.$auth.user.sub,
            team_id: team_choosen.id
          })
          .then(response => {
            // console.log(response);
            this.$auth.roles =  response.data.data.roles;
            loadingComponent.close();
            // TODO: why does this not propagate changes?
            // this.$router.push("/manage/events");
            location.reload();
          })
          .catch(error => {
            loadingComponent.close();
            this.displayErrorMessage(error);
          });
      },
      getTeamName(team_id){
        var valObj = this.optionsTeam.filter(function(elem){
          if(elem.id == team_id) return elem;
        });

        if(valObj.length > 0)
          return valObj[0].name
      }
    },

  }
</script>

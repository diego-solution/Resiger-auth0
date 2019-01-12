<template>
  <section>
    <vue-headful title="Confirm Presence"/>

    <div class="t-template confirmation">

      <div class="container o-placeholders" v-if="isLoading">
        <div class="columns">
          <div class="column is-6 is-offset-3 o-placeholders__intro">
            <div class="a-placeholder title"></div>
            <div class="a-placeholder subtitle"></div>
            <div class="a-placeholder text"></div>
            <div class="a-placeholder reg-button"></div>
          </div>
        </div>
      </div>

      <transition name="loading">
        <div class="container m-event" v-if="!isLoading">
          <div class="columns">
            <div class="column is-6 is-offset-3 m-event__header has-text-centered">
              <div v-html="page_content.header_html"></div>
                <br>
                <p>{{ t("confirmation.form.text") }}</p>
                <!-- Okay Animation -->
                <div style="min-height: 100px;">
                  <div class="check_mark" :class="{'Hide-me': !confirmButton }">
                    <div class="sa-icon sa-success animate">
                      <span class="sa-line sa-tip animateSuccessTip"></span>
                      <span class="sa-line sa-long animateSuccessLong"></span>
                      <div class="sa-placeholder"></div>
                      <div class="sa-fix"></div>
                    </div>
                  </div>
                  <!-- Cross Animation -->
                  <div class="cross-icon cross-delete animateDeleteIcon" :class="{'Hide-me': !declineButton}">
                    <span class="cross-x-mark animateXMark">
                      <span class="cross-delete-line cross-delete-left"></span>
                      <span class="cross-delete-line cross-delete-right"></span>
                    </span>
                  </div>
                </div>
                <div class="conformation-group">
                  <button :class="{ 'conformation-activate': declineButton }" @click.prevent="cancelRegistration"> {{ t("confirmation.button.decline") }} </button>
                  <button :class="{ 'conformation-activate': confirmButton }" @click.prevent="fetchData"> {{ t("confirmation.button.confirm") }} </button>
                </div>
            </div>
          </div>
        </div>
      </transition>

      <footer-register v-if="!isLoading">
        <div v-html="page_content.footer_html"></div>
      </footer-register>

    </div>
  </section>
</template>

<script>
import { messages } from '../../mixins/messages'
import { helpers } from '../../mixins/helpers'
import { translate } from '../../mixins/translations'

export default {
  name: 'ConfirmationRegistrant',
  mixins: [translate, messages, helpers],
  props: ['id', 'token', 'action'],
  data(){
    return{
      declineButton: false,
      confirmButton: false,
      page_content: Object,
      isLoading: true
    }
  },
  created () {
    var that = this
    this.fetchEvent()
  },
  methods: {
    // load data
    fetchData() {
      this.finishRegistration("confirm")
    },
    fetchEvent(){
      this.isLoading = true
      this.$http.get('/events/' + this.id + "/public").then((response) => {
        var registration_event = response.data.data
        this.page_content = registration_event.page_content
        this.registration_event = registration_event
        this.loadTranslations(registration_event.translations)
        this.isLoading = false
      }, (server_response) => {
        this.isLoading = false
        this.$router.push("/event-not-found")
        this.displayErrorMessage(server_response);
      })
    },
    cancelRegistration(){
      this.finishRegistration("cancel")
    },
    finishRegistration(action){
      const loadingComponent = this.$loading.open()
      this.$http.put('/events/' + this.id + "/registrants/" + this.token + "/confirm",{
        option: action
      }).then((response) => {
        loadingComponent.close()
        var status = response.data.message
        this.confirmButton = true
        this.declineButton = false
        if(action=="cancel"){
          this.declineButton = true
          this.confirmButton = false
        }
      }, (error) => {
        loadingComponent.close()
        this.displayErrorMessage(error);
      })
    }
  }
}
</script>

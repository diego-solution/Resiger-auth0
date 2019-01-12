<template>
  <section>
    <div class="container">
      <div class="columns">
        <div class="column is-6 is-offset-3 t-login">
          <img src="~images/ef.png" width=35 alt="Eventfuel">
          <h2>EventFuel Register</h2>
          <p v-if="$route.query.redirect">
            You need to login first.
          </p>
          <br>
          <button type="submit" class="button is-black" @click="login">Log in</button>
        </div>
      </div>
    </div>
  </section>
</template>

<script>
  export default {
    data () {
      return {
        error: false
      }
    },
    methods: {
      login () {
        this.$router.push(this.$route.query.redirect || '/manage')
      }
    }
  }
</script>

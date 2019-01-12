<template>
  <div class="t-template">
    <vue-headful title="The user has not been synced"/>

    <section>
      <div class="container m-event">
        <div class="columns">
          <div class="column is-8 is-offset-2 has-text-centered m-event__not-found">
            <img src="~/images/not-found.svg" alt="not found">
            <h1>Syncing your account</h1>
            <p>We were unable to find your account details, please contact Eventfuel support.</p>
          </div>
        </div>
      </div>
      <footer-register></footer-register>
    </section>
  </div>
</template>

<script>

export default {
  name: 'NotFoundUser',
  data() {
    return {
    }
  }
}
</script>

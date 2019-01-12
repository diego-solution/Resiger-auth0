<template>
  <div class="callback">Loading...</div>
</template>

<script>
export default {
  name: 'callback',
  props: ['auth'],
  mounted() {
    // console.log("Entered Callback");
    this.$auth.handleAuthentication()
      .then(() => {
        // console.log("roles fetch done and auth is done?");
        this.$router.push({ name: 'listEvents' })
      })
      .catch((err) => {
        // NOTE: not exist user here, show message and redirect login
        if (err.code === 404 && err.debug_info ==="notFoundUser") {
          this.$auth.logoutToSyncAccount();
        } else {
          this.$auth.logout();
        }
      });
  }
}
</script>

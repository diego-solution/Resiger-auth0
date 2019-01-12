<template>
  <div id="app" v-bind:class="{ white: this.$route.meta.fullPage }">
    <template v-if="$route.matched.length">
      <router-view></router-view>
    </template>
  </div>
</template>

<script>
  export default {
    name: 'app'
  }
</script>

netivity-vue-component<template>
 <div class="some-file"></div>
</template>

<style lang="scss">
@import './some-file.scss';
</style>

<script lang="ts">
import { Component, Vue } from 'vue-property-decorator';

@Component({ name: 'some-file' })
export default class some-file extends Vue {}
</script>


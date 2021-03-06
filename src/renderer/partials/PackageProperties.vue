<template>
  <form
    id="packageProperties"
    class="navbar-form form-horizontal">
    <div class="form-group-sm row container-fluid">
      <div
        v-for="(formprop, index) in formprops"
        :key="index"
        class="propertyrow">
        <label
          v-tooltip.left="tooltip(formprop.tooltipId)"
          :for="formprop.label"
          class="control-label col-sm-3">{{ formprop.label }}</label>
        <component :is="formprop.tooltipView"/>
        <component
          v-if="isSharedComponent(formprop.key)"
          :propertyName="formprop.key"
          :getProperty="getProperty"
          :getPropertyGivenHotId="getPropertyGivenHotId"
          :setProperty="setProperty"
          :waitForHotIdFromTabId="waitForHotIdFromTabId"
          :currentHotId="currentHotId"
          :is="formprop.key"/>
        <!-- <input v-else type="text" class="form-control input-sm col-sm-9" :id="formprop.key" :value="getProperty(formprop.key)" @input="setProperty(formprop.key, $event.target.value)"/> -->
        <textarea
          v-else-if="formprop.key === 'description'"
          :value="getProperty(formprop.key)"
          :id="formprop.key"
          rows="4"
          class="form-control label-sm col-sm-9"
          @input="setProperty(formprop.key, $event.target.value)" />
        <input
          v-validate="validationRules(formprop.key)"
          v-else
          :class="{ 'form-control input-sm col-sm-9': true, 'validate-danger': errors.has(formprop.key) }"
          :id="formprop.key"
          :value="getProperty(formprop.key)"
          :name="formprop.key"
          type="text"
          @input="setProperty(formprop.key, $event.target.value)">
        <div
          v-show="errors.has(formprop.key) && removeProperty(formprop.key)"
          class="row help validate-danger">
          {{ errors.first(formprop.key) }}
        </div>
      </div>
    </div>
  </form>
</template>
<script>
import SideNav from '@/partials/SideNav'
import licenses from '@/partials/Licenses'
import sources from '@/partials/Sources'
import contributors from '@/partials/Contributors'
import PackageTooltip from '@/mixins/PackageTooltip'
import ValidationRules from '@/mixins/ValidationRules'
import { ipcRenderer as ipc } from 'electron'
import {
  mapMutations,
  mapGetters
} from 'vuex'
import autosize from 'autosize'
export default {
  name: 'Packager',
  components: {
    licenses,
    sources,
    contributors
  },
  extends: SideNav,
  mixins: [ValidationRules, PackageTooltip],
  data() {
    return {
      formprops: [{
        label: 'Name*',
        key: 'name',
        tooltipId: 'tooltip-package-name',
        tooltipView: 'tooltipPackageName'
      },
      {
        label: 'Id',
        key: 'id',
        tooltipId: 'tooltip-package-id',
        tooltipView: 'tooltipPackageId'
      },
      {
        label: 'Title',
        key: 'title',
        tooltipId: 'tooltip-package-title',
        tooltipView: 'tooltipPackageTitle'
      },
      {
        label: 'Description',
        key: 'description',
        tooltipId: 'tooltip-package-description',
        tooltipView: 'tooltipPackageDescription'
      },
      // lead user through with http://frictionlessdata.io/specs/patterns/#data-package-version
      {
        label: 'Version',
        key: 'version',
        tooltipId: 'tooltip-package-version',
        tooltipView: 'tooltipPackageVersion'
      },
      {
        label: 'Source(s)',
        key: 'sources',
        tooltipId: 'tooltip-package-sources',
        tooltipView: 'tooltipPackageSources'
      },
      {
        label: 'License(s)',
        key: 'licenses',
        tooltipId: 'tooltip-package-licenses',
        tooltipView: 'tooltipPackageLicenses'
      },
      {
        label: 'Contributor(s)',
        key: 'contributors',
        tooltipId: 'tooltip-package-contributors',
        tooltipView: 'tooltipPackageContributors'
      }],
      hasPreferences: ['contributors', 'licenses']
    }
  },
  computed: {
    ...mapGetters(['getPackageProperty'])
  },
  mounted: function() {
    autosize(document.querySelector('textarea'))
  },
  methods: {
    ...mapMutations([
      'pushPackageProperty'
    ]),
    getProperty: function(key) {
      let packageProperty = this.getPackageProperty({
        'key': key
      })
      if (typeof packageProperty === 'undefined') {
        packageProperty = this.setPreferencesAsDefault(key)
      }
      return packageProperty
    },
    setPreferencesAsDefault: function(key) {
      if (_.indexOf(this.hasPreferences, key) > -1) {
        const packageProperty = ipc.sendSync('getPreference', key)
        this.setProperty(key, packageProperty)
        return packageProperty
      }
    },
    getPropertyGivenHotId: function(key, hotId) {
      return this.getProperty(key)
    },
    setProperty: function(key, value) {
      this.pushPackageProperty({
        key: key,
        value: value
      })
    },
    removeProperty: function(key) {
      let value = ''
      this.setProperty(key, value)
      return true
    }
  }
}
</script>
<style lang="styl" scoped>
@import '~static/css/validationrules'
</style>
<style lang="styl" scoped>
@import '~static/css/sidenav'
</style>

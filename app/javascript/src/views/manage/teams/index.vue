<template>
  <div class="columns">
    <div class="column is-12">
      <navigation-filters
        title="Teams" buttonAction="/manage/teams/new" buttonName="New Team">
      </navigation-filters>

      <div class="o-white-container">
        <data-table
          :rows="teams"
          :total="total"
          defaultSortField="name"
          defaultSortOrder="desc"
          @fetchData="fetchData"
          @deleteData="onDeleteData"
          :showDelete="true">
          <template slot="insideTableBody" slot-scope="justTheSlotScope">
            <b-table-column field="name" label="Name" sortable>
              <router-link :to="{ name: 'editTeam', params: { id: justTheSlotScope.props.row.id }}" class="a-link-blue">{{ justTheSlotScope.props.row.name }}</router-link>
            </b-table-column>
          </template>
        </data-table>
      </div>
    </div>
  </div>
</template>

<script>
  import { messages } from '../../../mixins/messages'

  export default {
    name: 'ListTeams',
    data(){
      return{
        teams: [],
        total: 0
      }
    },
    mixins: [messages],
    created (){
      this.fetchData()
    },
    methods: {
      // load data
      fetchData(sortParams) {
        debugger;
        if(sortParams == undefined)
          sortParams = ""

        const loadingComponent = this.$loading.open()
        this.$http.get("/teams?" + sortParams).then((response) => {
          this.teams = response.data.data
          this.total = response.data.paginatiπon.total_count
        }, (error) => {
          this.displayErrorMessage(error);
          this.teams = []
          this.total = 0
        })
        loadingComponent.close()
      },
      onDeleteData(rowsToDelete){
        const loadingComponent = this.$loading.open()
        this.$http.post('/teams/destroy_all', {
          teams: rowsToDelete
        }).then((response) => {
          loadingComponent.close()
          this.fetchData()
          this.displaySuccessMessage(response);
        }, (error) => {
          loadingComponent.close()
          this.displayErrorMessage(error);
        })
      }
    }
  }
</script>

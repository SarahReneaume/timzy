class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]
  skip_after_action :verify_policy_scoped, only: :index

  def index
    @team = Team.find(params[:id])
  end

  def show
    @comment = Comment.new
    authorize(@project)
    @ga = GoogleApi::Analytics.new(@project.team.admin)
    @service = @ga.service
    @datasession = @service.get_ga_data("ga:#{@project.team.view_id}", "30daysAgo", "yesterday", "ga:sessions", dimensions: "ga:date", filters: "ga:pagePath==/evaluation/prix-m2")
    @arraysession = @datasession.rows
    @graphsession = []
    @arraysession.each do |data|
      hash = {}
      hash[:x] = data[0]
      hash[:y] = data[1]
      @graphsession << hash
    end
    @datasuser = @service.get_ga_data("ga:#{@project.team.view_id}", "30daysAgo", "yesterday", "ga:users", dimensions: "ga:date", filters: "ga:pagePath==/evaluation/prix-m2")
    @arrayuser = @datasuser.rows
    @graphuser = []
    @arrayuser.each do |data|
      hash = {}
      hash[:x] = data[0]
      hash[:y] = data[1]
      @graphuser << hash
    end
    @datapv = @service.get_ga_data("ga:#{@project.team.view_id}", "30daysAgo", "yesterday", "ga:pageviews", dimensions: "ga:date", filters: "ga:pagePath==/evaluation/prix-m2")
    @arraypv = @datapv.rows
    @graphpv = []
    @arraypv.each do |data|
      hash = {}
      hash[:x] = data[0]
      hash[:y] = data[1]
    @graphpv << hash
    end
    @databr = @service.get_ga_data("ga:#{@project.team.view_id}", "30daysAgo", "yesterday", "ga:bounceRate", filters: "ga:pagePath==/evaluation/prix-m2")
    @data_br = [ @databr.rows.first.first.to_f, 100 - @databr.rows.first.first.to_f ]
    @datanv = @service.get_ga_data("ga:#{@project.team.view_id}", "30daysAgo", "yesterday", "ga:percentNewSessions", filters: "ga:pagePath==/evaluation/prix-m2")
    @data_nv = [ @datanv.rows.first.first.to_f, 100 - @datanv.rows.first.first.to_f ]
  end

  def new
    @project = Project.new
    @team = Team.find(params[:team_id])
    authorize(@project)
  end

  def create
    @project = Project.new(project_params)
    @project.user = current_user
    @team = Team.find(params[:team_id])
    @project.team = @team
    @gakpi = GoogleApi::Analytics.new(@project.team.admin)
    authorize(@project)
    if @project.save
      redirect_to team_path(@team) , notice: 'Your project was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @project.update(project_params)
      redirect_to project_path(@project) , notice: 'Your project was successfully updated.'
    else
      render :edit
    end
  end

   def destroy
    @team = Project.find(params[:id]).team
    @project.destroy
    redirect_to team_path(@team), notice: 'Your project was successfully destroyed.'
  end


private

  def project_params
    params.require(:project).permit(:title, :description, :start_date, :end_date, :goal, :kpi, :url_targeted, :category, :user_id, :team_id)
  end

end

  def set_project
    @project = Project.find(params[:id])
    authorize(@project)
  end

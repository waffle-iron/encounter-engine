class GameStatsController < ApplicationController
  before_action :find_game, :except => [:index]
  before_action :find_team, :only => [:adjustments]
  before_action :find_game_passing, :only => [:adjustments]
  before_action :find_game_passings, :except => [:index]
  before_action :ensure_team_member, :only => [:finish]
  before_action :ensure_author, :only => [:publish, :takedown]

  def index
    @games = Game.results_available_for(current_user)
    render
  end

  def show
    render
  end

  def adjustments
    render
  end

  def finish
    render
  end

  def publish
    GameInteractors::Publish.call({:game => @game})
    redirect_back :fallback_location => game_stats_path(@game)
  end

  def takedown
    GameInteractors::Takedown.call({:game => @game})
    redirect_back :fallback_location => game_stats_path(@game)
  end

  protected

  def render_sidebar?
    action_name === 'index' || action_name === 'finish'
  end

  private

  def find_game
    @game = Game.find params[:game_id]
  end

  def find_team
    @team = Team.friendly.find params[:team_id]
  end

  def find_game_by_id
    @game = Game.find params[:id]
  end

  def find_game_passing
    @game_passing = GamePassing.of(@team, @game)
  end

  def find_game_passings
    @game_passings = GamePassing.of_game(@game)
  end
end

# -*- encoding : utf-8 -*-

require 'time'

class GamesController < ApplicationController
  before_action :authenticate_user!, :except => [:index, :show]
  before_action :build_game, :only => [:new, :create]
  before_action :find_game, :only => [:show, :edit, :update, :destroy, :end_game]
  before_action :find_team, :only => [:show]
  before_action :ensure_author_if_game_is_draft, :only => [:show]
  before_action :ensure_author_if_no_start_time, :only => [:show]
  before_action :ensure_author, :only => [:edit, :update]
  before_action :ensure_game_was_not_started, :only => [:edit, :update]

  def index
    unless params[:user_id].blank?
      user = User.find(params[:user_id])
      @games = user.created_games
    else
      @games = Game.non_drafts
    end
    render
  end

  def new
    preset_default_values(@game)
    render
  end

  def create
    if @game.save
      redirect_to @game
    else
      render :new
    end
  end

  def show
    @game_entries = GameEntry.of_game(@game).with_status("new")
    @teams = []
    GameEntry.of_game(@game).with_status("accepted").each do |entry|
      @teams << Team.find(entry.team_id)
    end
    render
  end

  def edit
    render
  end

  def update
    if @game.update_attributes(game_params)
      redirect_to @game
    else
      render :edit
    end
  end

  def destroy
    @game.destroy
    redirect_to :dashboard
  end

  def end_game
    @game.finish_game!
    game_passings = GamePassing.of_game(@game)
    game_passings.each do |gp|
      gp.end!
    end
    redirect_to :dashboard
  end

  def start_test
    game = self.find_game
    game.preserved_data[:starts_at] = game.starts_at
    game.preserved_data[:registration_deadline] = game.registration_deadline
    game.is_draft = false
    game.is_testing = true
    game.author_finished_at = nil
    game.starts_at = Time.now + 0.1.second
    game.registration_deadline = nil
    game.save!
    sleep(rand(1))

    redirect_to @game
  end

  def finish_test
    game = self.find_game
    game.is_draft = true
    game.is_testing = false
    game.author_finished_at = nil
    game.starts_at = game.preserved_data[:starts_at] > Time.now ? game.preserved_data[:starts_at] : Time.now + 1.day
    game.registration_deadline = game.preserved_data[:registration_deadline] > Time.now ? game.preserved_data[:registration_deadline] : game.starts_at - 1.hour
    game.save!

    game_passing = GamePassing.of_game(game)
    logs = Log.of_game(game)

    game_passing.delete_all
    logs.delete_all

    redirect_to @game
  end

  protected

  def game_params   
    if params[:game].nil?
      return Hash.new
    end    
    
    data = params[:game].permit(:name, :description, :notes, :accessories, :starts_at, :finished_at, :registration_deadline, :max_team_number, :is_draft, :poster, :poster_cache)
    data
  end

  def preset_default_values(game)
    game.max_team_number = 10
    game.notes = """
<p>Территория: Ульяновск + 10км
    """
    game.accessories = """
<ul>
<li>Телефон с выходом в интернет
<li>Фонарь
<li>Автомобиль
<li>Командное соглашение
<li>Взнос на игру
</ul>
    """
  end

  def build_game
    @game = Game.new(game_params)
    @game.author = current_user
    @game
  end

  def find_game
    @game = Game.find(params[:id])
  end

  def game_is_draft?
    @game.draft?
  end

  def find_team
    if current_user
      @team = current_user.team
    else
      @team = nil
    end
  end

  def no_start_time?
    @game.starts_at.nil?
  end

  def ensure_author_if_game_is_draft
    ensure_author if game_is_draft?
  end

  def ensure_author_if_no_start_time
    ensure_author if no_start_time?
  end
end

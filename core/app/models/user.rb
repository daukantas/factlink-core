require 'open-uri'
require 'digest/md5'

class User
  include Mongoid::Document
  include Sunspot::Mongoid

  # TODO: remove name attribute after relase of sprint 20
  field :name

  field :username
  index :username
  field :first_name
  field :last_name

  field :twitter
  field :graph_user_id

  field :admin,       type: Boolean, default: false
  field :agrees_tos,  type: Boolean, default: false
  field :agrees_tos_name, type: String, default: ""
  field :agreed_tos_on,   type: DateTime

  field :seen_the_tour,  type: Boolean, default: false

  field :last_read_activities_on, type: DateTime, default: 0

  attr_accessible :username, :first_name, :last_name, :twitter, :password, :password_confirmation
  attr_accessible :agrees_tos_name, :agrees_tos, :agreed_tos_on, as: :from_tos

  # Only allow letters, digits and underscore in a username
  validates_format_of     :username, :with => /^[A-Za-z0-9_]+$/, :message => "only letters, digits and _ are allowed"
  validates_presence_of   :username, :message => "is required", :allow_blank => true
  validates_uniqueness_of :username, :message => "must be unique"
  validates_length_of     :username, :within => 1..16, :message => "maximum of 16 characters allowed"

  before_validation :downcase_username
  def downcase_username
    self.username.downcase!
  end

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :lockable, :timeoutable and :omniauthable,
  devise :database_authenticatable,
  :recoverable,   # Password retrieval
  :rememberable,  # 'Remember me' box
  :trackable,     # Log sign in count, timestamps and IP address
  :validatable,   # Validation of email and password
  :confirmable   # Require e-mail verification
  # :registerable   # Allow registration

  ## Database authenticatable
    field :email,              :type => String, :null => false
    field :encrypted_password, :type => String, :null => false

  ## Recoverable
    field :reset_password_token,   :type => String
    field :reset_password_sent_at, :type => Time

  ## Rememberable
    field :remember_created_at, :type => Time

  ## Trackable
    field :sign_in_count,      :type => Integer
    field :current_sign_in_at, :type => Time
    field :last_sign_in_at,    :type => Time
    field :current_sign_in_ip, :type => String
    field :last_sign_in_ip,    :type => String

  ## Confirmable
    field :confirmation_token,   :type => String
    field :confirmed_at,         :type => Time
    field :confirmation_sent_at, :type => Time


  searchable :auto_index => true do
    text    :username, :twitter
    string  :username, :twitter
  end

  def graph_user
    @graph_user ||= GraphUser[graph_user_id]
  end

  def graph_user=(guser)
    @graph_user = nil
    self.graph_user_id = guser.id
  end

  def create_graph_user
    guser = GraphUser.new
    guser.save
    self.graph_user = guser

    yield

    guser.user = self
    guser.save
  end

  def sign_tos(agrees_tos, agrees_tos_name)
    valid = true
    unless agrees_tos
      valid = false
      self.errors.add("", "You have to accept the Terms of Service to continue.")
    end
    if agrees_tos_name.blank?
      valid = false
      self.errors.add("", "Please fill in your name to accept the Terms of Service.")
    end

    if valid and self.assign_attributes({agrees_tos: agrees_tos, agrees_tos_name: agrees_tos_name, agreed_tos_on: DateTime.now}, as: :from_tos) and save
      true
    else
      false
    end
  end

  private :create_graph_user #WARING!!! is called by the database reset function to recreate graph_users after they were wiped, while users were preserved
  around_create :create_graph_user

  def to_s
    username
  end

  def to_param
    username
  end

  def serializable_hash(options={})
    options ||= {}
    options[:except] ||= Array.new
    options[:except] += [:admin, :agrees_tos, :agreed_tos_on, :agrees_tos_name, ]
    super(options)
  end

  def self.from_param(param)
    self.first :conditions => { username: param }
  end

  def self.find(param,*args)
    super
  rescue
    from_param(param)
  end

  def avatar_url(options={})
    options[:default] ||= :retro
    options[:rating] ||= :PG
    gravatar_url(email,options)
  end

  private
    # from: http://douglasfshearer.com/blog/gravatar-for-ruby-and-ruby-on-rails
    # Returns a Gravatar URL associated with the email parameter.
    #
    # Gravatar Options:
    # - rating: Can be one of G, PG, R or X. Default is X.
    # - size: Size of the image. Default is 80px.
    # - default: URL for fallback image if none is found or image exceeds rating.
    def gravatar_url(email,gravatar_options={})
      grav_url = 'https://secure.gravatar.com/avatar/'
      grav_url << "#{Digest::MD5.new.update(email)}?"
      grav_url << (gravatar_options.slice(:rating,:size,:default).map{|k,v| "#{k}=#{v}"}.join "&")
      grav_url
    end

end

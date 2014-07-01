class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :trackable, :validatable

  serialize :tokens, JSON

  def valid_token?(client_id, token)
    BCrypt::Password.new(self.tokens[client_id]) == token
  end
end

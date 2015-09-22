class Custom::TokenValidationsController < DeviseTokenAuth::TokenValidationsController

  def validate_token
    super do |resource|
      @validate_token_block_called = true
    end
  end

  def validate_token_block_called?
    @validate_token_block_called == true
  end

  protected

  def render_token_validations_controller_validate_token_success
    render json: {custom: "foo"}
  end

end

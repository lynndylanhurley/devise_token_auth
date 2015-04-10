class Custom::SessionsController < DeviseTokenAuth::SessionsController

  def create
    super do |resource|
      @create_block_called = true
    end
  end

  def destroy
    super do |resource|
      @destroy_block_called = true
    end
  end

  def create_block_called?
    @create_block_called == true
  end

  def destroy_block_called?
    @destroy_block_called == true
  end

end

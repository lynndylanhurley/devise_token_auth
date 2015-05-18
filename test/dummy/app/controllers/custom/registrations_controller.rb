class Custom::RegistrationsController < DeviseTokenAuth::RegistrationsController

  def create
    super do |resource|
      @create_block_called = true
    end
  end

  def update
    super do |resource|
      @update_block_called = true
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

  def update_block_called?
    @update_block_called == true
  end

  def destroy_block_called?
    @destroy_block_called == true
  end

end

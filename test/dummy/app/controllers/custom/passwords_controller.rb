class Custom::PasswordsController < DeviseTokenAuth::PasswordsController

  def create
    super do |resource|
      @create_block_called = true
    end
  end

  def edit
    super do |resource|
      @edit_block_called = true
    end
  end

  def update
    super do |resource|
      @update_block_called = true
    end
  end

  def create_block_called?
    @create_block_called == true
  end

  def edit_block_called?
    @edit_block_called == true
  end

  def update_block_called?
    @update_block_called == true
  end



end

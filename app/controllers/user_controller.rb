class UserController < ApplicationController
	def client
	end
	def login
		user = param[:user]
		pswd = param[:password]
		info = UserModel.find(:first, :conditions => ["user = :u", {:u => user}, "password = :p", {:p => pswd} ])
		if !info.nil?
			info.update_attribute(:count => info.count+1)
			render :json => {:errCode => 1, :count => info.count+1}
		
		else
			render :json => {:errCode => -1}
		end
	end

	def add
		user = param[:user]
		pswd = param[:password]
		if user.empty?
		       render :json => {:errCode => -3}
		
		elsif pswd.bytesize > 128
			render :json => {:errCode => -4}
		
		elsif !UserModel.find('user').nil?
			render :json => {:errCode => -2}
		else
			UserModel.create(:user=>user, :pswd=>pswd, :count=>1)
			render :json => {:errCode => 1, :count => 1}
		end

	end

	def resetFixture
		UserModel.delete_all()
		render :json => {:errCode => 1}
	end

	def unitTests
	
	end

end

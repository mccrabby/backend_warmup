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
		numFailed = 0
		numRan = 0
		#test1 checks what happens when you log in using nonexistant info
		test1 = json_decode(login('user', 'pswd'))
		if test1.errCode != -1
			numFailed = numFailed + 1
		end
		numRan = numRan+1
		#test2 adds a user to database
		test2 = json_decode(add('user', 'pswd'))
		if test2.errCode != 1 or test2.count != 1
			numFailed = numFailed + 1
		end
		numRan = numRan+1
		#test3 logs in with incorrect password
		test3 = json_decode(login('user', '1234'))
		if test3.errCode != -1
			numFailed = numFailed + 1
		end
		numRan = numRan+1
		#test4 logs in with incorrect username
		test4 = json_decode(login('person', 'pswd'))
		if test4.errCode != -1
			numFailed = numFailed + 1
		end
		numRan = numRan+1
		#test5 logs in with correct user and password
		oldCount = UserModel.find('user').count
		test5 = json_decode(login('user', 'pswd'))
		if test5.errCode != 1 or test5.count != oldCount+1
			numFailed = numFailed + 1
		end
		numRan = numRan+1
		#test6 logs in again to verify count is being kept track of
		oldCount = UserModel.find('user').count
		test6 = json_decode(login('user', 'pswd'))
		if test6.errCode != 1 or test6.count != oldCount+1
			numFailed = numFailed + 1
		end
		numRan = numRan+1
		#test7 adds another user
	 	test7 = json_decode(add('name', '1234'))
		if test7.errCode != 1 or test7.count != 1
			numFailed = numFailed + 1
		end
		numRan = numRan+1
		#test8 logs in using a password from a different username
		test8 = json_decode(login('name', 'pswd'))
		if test8.errcode != -1
			numFailed = numFailed + 1
		end
		numRan = numRan+1
		#test9 adds a user that already exists
		test9 = json_decode(add('name', 'pswd'))
		if test9.errCode != -2
			numFailed = numFailed + 1
		end
		numRan = numRan+1
		#test10 adds a user with a blank username
		test10 = json_decode(add('', 'word'))
		if test10.errCode == -3
			numFailed = numFailed + 1
		end
		numRan = numRan+1
	
		result = 'All tests ran succesfully'
		if numRan < 10
			result = 'Not all the tests were run successfully'
		end

		render :json => {:totalTests => numRan, :nrFailed => numFailed, :output => result}
		
	end

end

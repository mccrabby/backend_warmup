import unittest
import os
import testLib

class TestUnit(testLib.RestTestCase):
    """Issue a REST API request to run the unit tests, and analyze the result"""
    def testUnit(self):
        respData = self.makeRequest("/TESTAPI/unitTests", method="POST")
        self.assertTrue('output' in respData)
        print ("Unit tests output:\n"+
               "\n***** ".join(respData['output'].split("\n")))
        self.assertTrue('totalTests' in respData)
        print "***** Reported "+str(respData['totalTests'])+" unit tests"
        # When we test the actual project, we require at least 10 unit tests
        minimumTests = 10
        if "SAMPLE_APP" in os.environ:
            minimumTests = 4
        self.assertTrue(respData['totalTests'] >= minimumTests,
                        "at least "+str(minimumTests)+" unit tests. Found only "+str(respData['totalTests'])+". use SAMPLE_APP=1 if this is the sample app")
        self.assertEquals(0, respData['nrFailed'])


        
class TestAddUser(testLib.RestTestCase):
    """Test adding users"""
    def assertResponse(self, respData, count = 1, errCode = testLib.RestTestCase.SUCCESS):
        """
        Check that the response data dictionary matches the expected values
        """
        expected = { 'errCode' : errCode }
        if count is not None:
            expected['count']  = count
        self.assertDictEqual(expected, respData)

    def testAdd1(self):
        respData = self.makeRequest("/users/add", method="POST", data = { 'user' : 'user1', 'password' : 'password'} )
        self.assertResponse(respData, count = 1)

    """try adding user with blank name"""
    def testAdd2(self):
        respData = self.makeRequest("/users/add", method="POST", data = { 'user' : '', 'password' : 'pswd'} )
        self.assertResponse(respData, errCode = -3)

    """try adding existing user"""
    def testAdd3(self):
        self.makeRequest("/users/add", method="POST", data = { 'user' : 'user2', 'password' : 'pswd'} )
        respData = self.makeRequest("/users/add", method="POST", data = { 'user' : 'user2', 'password' : 'pswd'} )
        self.assertResponse(respData, errCode = -2)


class TestLoginUser(testLib.RestTestCase):
    """Test logging in users"""
    def assertResponse(self, respData, count = 1, errCode = testLib.RestTestCase.SUCCESS):
        """
        Check that the response data dictionary matches the expected values
        """
        expected = { 'errCode' : errCode }
        if count is not None:
            expected['count']  = count
        self.assertDictEqual(expected, respData)

    """logs in with non existing user"""
    def testLogin4(self):
        respData = self.makeRequest("/users/login", method="POST", data = { 'user' : 'user4', 'password' : 'password'} )
        self.assertResponse(respData, errCode = -1)

    """logs in with wrong password"""
    def testLogin5(self):
        self.makeRequest("/users/add", method="POST", data = { 'user' : 'user5', 'password' : 'pswd'} )
        respData = self.makeRequest("/users/login", method="POST", data = { 'user' : 'user5', 'password' : 'password'} )
        self.assertResponse(respData, errCode = -1)

    """logs in using existing user with correct credentials"""
    def testLogin6(self):
        self.makeRequest("/users/add", method="POST", data = { 'user' : 'user6', 'password' : 'pswd'} )
        respData = self.makeRequest("/users/login", method="POST", data = { 'user' : 'user6', 'password' : 'pswd'} )
        self.assertResponse(respData, count = 2, errCode = -1)

/*============================================================================
  CMake - Cross Platform Makefile Generator
  Copyright 2000-2009 Kitware, Inc., Insight Software Consortium

  Distributed under the OSI-approved BSD License (the "License");
  see accompanying file Copyright.txt for details.

  This software is distributed WITHOUT ANY WARRANTY; without even the
  implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  See the License for more information.
============================================================================*/
#ifndef cmCTestRunTest_h
#define cmCTestRunTest_h

#include <cmStandardIncludes.h>
#include <cmCTestTestHandler.h>
#include <cmProcess.h>

/** \class cmRunTest
 * \brief represents a single test to be run
 *
 * cmRunTest contains the information related to running a single test
 */
class cmCTestRunTest
{
public:
  cmCTestRunTest(cmCTestTestHandler* handler);
  ~cmCTestRunTest();

  void SetTestProperties(cmCTestTestHandler::cmCTestTestProperties * prop)
  { this->TestProperties = prop; }

  cmCTestTestHandler::cmCTestTestProperties * GetTestProperties()
  { return this->TestProperties; }

  void SetIndex(int i) { this->Index = i; }

  int GetIndex() { return this->Index; }

  std::string GetProcessOutput() { return this->ProcessOutput; }

  cmCTestTestHandler::cmCTestTestResult GetTestResults()
  { return this->TestResult; }

  // Read and store output.  Returns true if it must be called again.
  bool CheckOutput();

  //launch the test process, return whether it started correctly
  bool StartTest();
  //capture and report the test results
  bool EndTest(size_t completed, size_t total, bool started);
  //Called by ctest -N to log the command string
  void ComputeArguments();
private:
  void DartProcessing();
  bool CreateProcess(double testTimeOut,
                     std::vector<std::string>* environment);
  void WriteLogOutputTop(size_t completed, size_t total);
  //Run post processing of the process output for MemCheck
  void MemCheckPostProcess();

  cmCTestTestHandler::cmCTestTestProperties * TestProperties;
  //Pointer back to the "parent"; the handler that invoked this test run
  cmCTestTestHandler * TestHandler;
  cmCTest * CTest;
  cmProcess * TestProcess;
  //If the executable to run is ctest, don't create a new process; 
  //just instantiate a new cmTest.  (Can be disabled for a single test
  //if this option is set to false.)
  //bool OptimizeForCTest;

  //flag for whether the env was modified for this run
  bool ModifyEnv;
  //stores the original environment if we are modifying it
  std::vector<std::string> OrigEnv;
  std::string ProcessOutput;
  //The test results
  cmCTestTestHandler::cmCTestTestResult TestResult;
  int Index;
  std::string StartTime;
  std::string TestCommand;
  std::string ActualCommand;
  std::vector<std::string> Arguments;
};

inline int getNumWidth(size_t n)
{
  int numWidth = 1;
  if(n >= 10)
    {
    numWidth = 2;
    }
  if(n >= 100)
    {
    numWidth = 3;
    }
  return numWidth;
}
#endif

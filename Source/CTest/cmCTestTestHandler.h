/*============================================================================
  CMake - Cross Platform Makefile Generator
  Copyright 2000-2009 Kitware, Inc.

  Distributed under the OSI-approved BSD License (the "License");
  see accompanying file Copyright.txt for details.

  This software is distributed WITHOUT ANY WARRANTY; without even the
  implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  See the License for more information.
============================================================================*/

#ifndef cmCTestTestHandler_h
#define cmCTestTestHandler_h


#include "cmCTestGenericHandler.h"
#include <cmsys/RegularExpression.hxx>

class cmMakefile;

/** \class cmCTestTestHandler
 * \brief A class that handles ctest -S invocations
 *
 */
class cmCTestTestHandler : public cmCTestGenericHandler
{
  friend class cmCTestRunTest;
  friend class cmCTestMultiProcessHandler;
  friend class cmCTestBatchTestHandler;
public:
  cmTypeMacro(cmCTestTestHandler, cmCTestGenericHandler);

  /**
   * The main entry point for this class
   */
  int ProcessHandler();

  /**
   * When both -R and -I are used should te resulting test list be the
   * intersection or the union of the lists. By default it is the
   * intersection.
   */
  void SetUseUnion(bool val) { this->UseUnion = val; }

  /**
   * This method is called when reading CTest custom file
   */
  void PopulateCustomVectors(cmMakefile *mf);

  ///! Control the use of the regular expresisons, call these methods to turn
  ///them on
  void UseIncludeRegExp();
  void UseExcludeRegExp();
  void SetIncludeRegExp(const char *);
  void SetExcludeRegExp(const char *);

  void SetMaxIndex(int n) {this->MaxIndex = n;}
  int GetMaxIndex() {return this->MaxIndex;}

  ///! pass the -I argument down
  void SetTestsToRunInformation(const char*);

  cmCTestTestHandler();

  /*
   * Add the test to the list of tests to be executed
   */
  bool AddTest(const std::vector<std::string>& args);

  /*
   * Set tests properties
   */
  bool SetTestsProperties(const std::vector<std::string>& args);

  void Initialize();

  // NOTE: This struct is Saved/Restored
  // in cmCTestTestHandler, if you add to this class
  // then you must add the new members to that code or
  // ctest -j N will break for that feature
  struct cmCTestTestProperties
  {
    cmStdString Name;
    cmStdString Directory;
    std::vector<std::string> Args;
    std::vector<std::string> RequiredFiles;
    std::vector<std::string> Depends;
    std::vector<std::string> AttachedFiles;
    std::vector<std::string> AttachOnFail;
    std::vector<std::pair<cmsys::RegularExpression,
                          std::string> > ErrorRegularExpressions;
    std::vector<std::pair<cmsys::RegularExpression,
                          std::string> > RequiredRegularExpressions;
    std::map<cmStdString, cmStdString> Measurements;
    bool IsInBasedOnREOptions;
    bool WillFail;
    float Cost;
    int PreviousRuns;
    bool RunSerial;
    double Timeout;
    bool ExplicitTimeout;
    int Index;
    //Requested number of process slots
    int Processors;
    std::vector<std::string> Environment;
    std::vector<std::string> Labels;
    std::set<std::string> LockedResources;
  };

  struct cmCTestTestResult
  {
    std::string Name;
    std::string Path;
    std::string Reason;
    std::string FullCommandLine;
    double      ExecutionTime;
    int         ReturnValue;
    int         Status;
    bool        CompressOutput;
    std::string CompletionStatus;
    std::string Output;
    std::string RegressionImages;
    int         TestCount;
    cmCTestTestProperties* Properties;
  };

  // add configuraitons to a search path for an executable
  static void AddConfigurations(cmCTest *ctest, 
                                std::vector<std::string> &attempted,
                                std::vector<std::string> &attemptedConfigs,
                                std::string filepath,
                                std::string &filename);

  // full signature static method to find an executable
  static std::string FindExecutable(cmCTest *ctest,
                                    const char *testCommand,
                                    std::string &resultingConfig,
                                    std::vector<std::string> &extraPaths,
                                    std::vector<std::string> &failed);

  typedef std::vector<cmCTestTestProperties> ListOfTests;
protected:
  // comput a final test list
  virtual int PreProcessHandler();
  virtual int PostProcessHandler();
  virtual void GenerateTestCommand(std::vector<std::string>& args);
  int ExecuteCommands(std::vector<cmStdString>& vec);

  void WriteTestResultHeader(std::ostream& os, cmCTestTestResult* result);
  void WriteTestResultFooter(std::ostream& os, cmCTestTestResult* result);
  // Write attached test files into the xml
  void AttachFiles(std::ostream& os, cmCTestTestResult* result);
  // Helper function to encode attached test files
  std::string EncodeFile(std::string file);

  //! Clean test output to specified length
  bool CleanTestOutput(std::string& output, size_t length);

  double                  ElapsedTestingTime;

  typedef std::vector<cmCTestTestResult> TestResultsVector;
  TestResultsVector    TestResults;

  std::vector<cmStdString> CustomTestsIgnore;
  std::string             StartTest;
  std::string             EndTest;
  unsigned int            StartTestTime;
  unsigned int            EndTestTime;
  bool MemCheck;
  int CustomMaximumPassedTestOutputSize;
  int CustomMaximumFailedTestOutputSize;
  int MaxIndex;
public:
  enum { // Program statuses
    NOT_RUN = 0,
    TIMEOUT,
    SEGFAULT,
    ILLEGAL,
    INTERRUPT,
    NUMERICAL,
    OTHER_FAULT,
    FAILED,
    BAD_COMMAND,
    COMPLETED
  };

private:
  /**
   * Generate the Dart compatible output
   */
  virtual void GenerateDartOutput(std::ostream& os);

  void PrintLabelSummary();
  /**
   * Run the tests for a directory and any subdirectories
   */
  void ProcessDirectory(std::vector<cmStdString> &passed,
                        std::vector<cmStdString> &failed);

  /**
   * Get the list of tests in directory and subdirectories.
   */
  void GetListOfTests();
  // compute the lists of tests that will actually run
  // based on union regex and -I stuff
  void ComputeTestList();
  
  bool GetValue(const char* tag,
                std::string& value,
                std::ifstream& fin);
  bool GetValue(const char* tag,
                int& value,
                std::ifstream& fin);
  bool GetValue(const char* tag,
                size_t& value,
                std::ifstream& fin);
  bool GetValue(const char* tag,
                bool& value,
                std::ifstream& fin);
  bool GetValue(const char* tag,
                double& value,
                std::ifstream& fin);
  /**
   * Find the executable for a test
   */
  std::string FindTheExecutable(const char *exe);

  const char* GetTestStatus(int status);
  void ExpandTestsToRunInformation(size_t numPossibleTests);

  std::vector<cmStdString> CustomPreTest;
  std::vector<cmStdString> CustomPostTest;

  std::vector<int>        TestsToRun;

  bool UseIncludeLabelRegExpFlag;
  bool UseExcludeLabelRegExpFlag;
  bool UseIncludeRegExpFlag;
  bool UseExcludeRegExpFlag;
  bool UseExcludeRegExpFirst;
  std::string IncludeLabelRegExp;
  std::string ExcludeLabelRegExp;
  std::string IncludeRegExp;
  std::string ExcludeRegExp;
  cmsys::RegularExpression IncludeLabelRegularExpression;
  cmsys::RegularExpression ExcludeLabelRegularExpression;
  cmsys::RegularExpression IncludeTestsRegularExpression;
  cmsys::RegularExpression ExcludeTestsRegularExpression;

  std::string GenerateRegressionImages(const std::string& xml);
  cmsys::RegularExpression DartStuff1;
  void CheckLabelFilter(cmCTestTestProperties& it);
  void CheckLabelFilterExclude(cmCTestTestProperties& it);
  void CheckLabelFilterInclude(cmCTestTestProperties& it);

  std::string TestsToRunString;
  bool UseUnion;
  ListOfTests TestList;
  size_t TotalNumberOfTests;
  cmsys::RegularExpression DartStuff;

  std::ostream* LogFile;
};

#endif

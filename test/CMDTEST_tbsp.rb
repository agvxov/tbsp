class CMDTEST_master_batch < Cmdtest::Testcase
  def test_converter
    import_file "test/convert.tbsp", "./"
    import_file "test/input.md", "./"

    cmd "tbsp -o convert.tb.c convert.tbsp" do
      created_files ["convert.tb.c"]
    end
    shell "bake convert.tb.c"
    cmd "./convert.tb.out input.md" do
      stdout_equal /.+/
    end
  end

  def test_function_collector
    import_file "test/function_collector.tbsp", "./"

    cmd "tbsp -o function_collector.tb.cpp function_collector.tbsp" do
      created_files ["function_collector.tb.cpp"]
    end
    shell "bake function_collector.tb.cpp"
    cmd "./function_collector.tb.out function_collector.tb.cpp" do
      stdout_equal /.+/
    end
  end
end

class CMDTEST_error_batch < Cmdtest::Testcase
  def test_double_top
    import_file "test/double_top.tbsp", "./"

    cmd "tbsp double_top.tbsp" do
      stderr_equal /.*top.*/
      exit_nonzero
    end
  end

  def test_no_language
    import_file "test/no_language.tbsp", "./"

    cmd "tbsp no_language.tbsp" do
      stderr_equal /.*language.*/
      exit_nonzero
    end
  end
end

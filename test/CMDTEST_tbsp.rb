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

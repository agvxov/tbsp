class CMDTEST_master_batch < Cmdtest::Testcase
  def setup
    import_file "test/file2str.h", "./"
  end

  def test_hw
    source = "hello_world2"

    import_file "test/#{source}.tbsp", "./"

    cmd "tbsp -o #{source}.tb.c #{source}.tbsp" do
      created_files ["#{source}.tb.c"]
    end
    cmd "gcc -w -o #{source}.out #{source}.tb.c $(pkg-config --cflags --libs tree-sitter tree-sitter-c)" do
      created_files ["#{source}.out"]
    end
    cmd "./#{source}.out" do
      stdout_equal /.+/
    end
  end

  def test_converter
    source = "convert"

    import_file "test/#{source}.tbsp", "./"
    import_file "test/input.md", "./"

    cmd "tbsp -o #{source}.tb.c #{source}.tbsp" do
      created_files ["#{source}.tb.c"]
    end
    cmd "gcc -w -o #{source}.out #{source}.tb.c $(pkg-config --cflags --libs tree-sitter) -ltree-sitter-markdown" do
      created_files ["#{source}.out"]
    end
    cmd "./#{source}.out input.md" do
      stdout_equal /.+/
    end
  end

  def test_function_collector
    source = "function_collector"

    import_file "test/#{source}.tbsp", "./"

    cmd "tbsp -o #{source}.tb.cpp #{source}.tbsp" do
      created_files ["#{source}.tb.cpp"]
    end
    cmd "g++ -w -o #{source}.out #{source}.tb.cpp $(pkg-config --cflags --libs tree-sitter tree-sitter-cpp)" do
      created_files ["#{source}.out"]
    end
    cmd "./#{source}.out #{source}.tb.cpp" do
      stdout_equal /.+/
    end
  end

  def test_double_selector
    source = "double_selector"

    import_file "test/#{source}.tbsp", "./"

    cmd "tbsp #{source}.tbsp" do
      created_files ["#{source}.tb.c"]
    end
    cmd "g++ -w -o #{source}.out #{source}.tb.c $(pkg-config --cflags --libs tree-sitter tree-sitter-c)" do
      created_files ["#{source}.out"]
    end
    cmd "./#{source}.out #{source}.tb.c" do
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

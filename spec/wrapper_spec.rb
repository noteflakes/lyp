require File.expand_path('spec_helper', File.dirname(__FILE__))

RSpec.describe "Lyp.wrap" do
  it "wraps a file without dependencies" do
    orig_fn = File.expand_path('user_files/no_require.ly', File.dirname(__FILE__))
    fn = Lyp.wrap(orig_fn)
    expect(fn).to_not eq(orig_fn)
  end

  it "creates a wrapper file containing dependency paths for a file with dependencies" do
    with_packages(:simple) do
      orig_fn = File.expand_path('user_files/simple.ly', File.dirname(__FILE__))
      fn = Lyp.wrap(orig_fn)
      expect(fn).to_not eq(orig_fn)

      code = IO.read(fn)

      expect(code).to include("(define lyp:input-filename \"#{orig_fn}\")")
      expect(code).to include("(define lyp:input-dirname \"#{File.dirname(orig_fn)}\")")

      expect(code).to include("(hash-set! lyp:package-refs \"a\" \"a\")")
      expect(code).to include("(hash-set! lyp:package-refs \"b@>=0.1.0\" \"b\")")
      expect(code).to include("(hash-set! lyp:package-refs \"b@~>0.2.0\" \"b\")")
      expect(code).to include("(hash-set! lyp:package-refs \"b~>0.1.0\" \"b\")")
      expect(code).to include("(hash-set! lyp:package-refs \"c\" \"c\")")

      expect(code).to include("(hash-set! lyp:package-dirs \"a\" \"#{$packages_dir}/a@0.1\")")
      expect(code).to include("(hash-set! lyp:package-dirs \"b\" \"#{$packages_dir}/b@0.1\")")
      expect(code).to include("(hash-set! lyp:package-dirs \"c\" \"#{$packages_dir}/c@0.1\")")
    end
  end

  it "preloads external requires (supplied on command line using -r/--require)" do
    with_packages(:simple) do
      orig_fn = File.expand_path('user_files/no_require.ly', File.dirname(__FILE__))
      fn = Lyp.wrap(orig_fn, ext_require: ['a'])
      expect(fn).to_not eq(orig_fn)

      code = IO.read(fn)

      expect(code).to include("(define lyp:input-filename \"#{orig_fn}\")")
      expect(code).to include("(define lyp:input-dirname \"#{File.dirname(orig_fn)}\")")

      expect(code).to include("(hash-set! lyp:package-refs \"a\" \"a\")")
      expect(code).to include("(hash-set! lyp:package-refs \"b@~>0.2.0\" \"b\")")

      expect(code).to include("(hash-set! lyp:package-dirs \"a\" \"#{$packages_dir}/a@0.2\")")
      expect(code).to include("(hash-set! lyp:package-dirs \"b\" \"#{$packages_dir}/b@0.2.2\")")

      expect(code).to include("\\require \"a\"")
    end
  end

  it "includes paper preamble on relevant option" do
    orig_fn = File.expand_path('user_files/no_require.ly', File.dirname(__FILE__))
    fn = Lyp.wrap(orig_fn, snippet_paper_preamble: true)
    expect(fn).to_not eq(orig_fn)

    code = IO.read(fn)
    expect(code).to include("indent = 0\\mm")

  end
end

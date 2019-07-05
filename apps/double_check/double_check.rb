


class DoubleCheck
	SEPARATOR = "==========================="

	@@create_test = ->(string, lamb) { [string, lamb] }
	
	@@op_lookup = ->(op_name) {
		case op_name
		when op_name.kind_of?(Array)
			op_name.last
		when "not_equal"
			->(x,y) { F.not.(F.equals.(x,y))}
		when "equal"
			F.equals
		when "not_eq"
			->(x,y) { F.not.(F.eq.(x,y))}
		when "eq"
			F.eq
		when "gte"
			F.gte
		when "gt"
			F.gt
		when "lte"
			F.lte
		when "lt"
			F.lt
		end
	}
	
	@@check = ->(op, is, should_be) { 
		op_name = op.kind_of?(Array) ? op.first : op
		message = "Expected #{is} should #{op_name} #{should_be}, but it does not"
		success = false
		new_exception = Exception.new(message)
		begin
			success = @@op_lookup.(op).(is, should_be)
		rescue Exception => e
			message += e.message
			new_exception = Exception.new(message)
			new_exception.set_backtrace(e.backtrace)
		end
		if not(success)
			puts("F]")
			raise new_exception
		else
			print(".") 
		end
		success
	}
	
	@@did_test_pass = ->(test_to_run) {
		puts(SEPARATOR)
		puts("Checking if #{test_to_run.first}")
		print("[")
		success = false
		begin
			test_to_run.last.()
			success = true
		rescue Exception => e
			puts("Error: #{e.message}")
			puts("At: ")
			puts(e.backtrace)
			puts(SEPARATOR)
			success = false
		end
		puts("]") if success
		success
	}
	
	@@did_test_fail = ->(test_to_run) { !@@did_test_pass.(test_to_run)}
	
	@@failure_report = ->(test_number, failures) { (puts("#{failures}") || puts("#{failures.length} Failures out of #{test_number} Tests:") || F.map.(->(failure) { puts failure.first; failure.first }).(failures)) if failures.length > 0 }
	
	@@run_tests = ->(tests_to_run) { @@failure_report.(tests_to_run.length) * ->(l) { l.select {|x| @@did_test_fail.(x) } } * ->(tests) { puts "Running #{tests.length} Tests"; puts(SEPARATOR); tests} <= tests_to_run }

	def initialize(tests)
		@tests = tests
	end

	def self.create_test
		@@create_test
	end

	def self.check
		@@check
	end
	
	def self.run_tests
		@@run_tests
	end

	def run(str="")
		@@run_tests.(@tests.select{|x| x.first.include?(str)})
	end

end

self.define_singleton_method('check') { DoubleCheck.check }
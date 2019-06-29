SEPARATOR = "==========================="

create_test = ->(string, lamb) { [string, lamb] }


op_lookup = ->(op_name) {
	case op_name
	when op_name.kind_of?(Array)
		op_name.last
	when "not_equal"
		->(x,y) { nt.(equals.(x,y))}
	when "equal"
		equals
	when "not_eq"
		->(x,y) { nt.(eq.(x,y))}
	when "eq"
		eq
	when "gte"
		gte
	when "gt"
		gt
	when "lte"
		lte
	when "lt"
		lt
	end
}

check = ->(op, is, should_be) { 
	op_name = op.kind_of?(Array) ? op.first : op
	message = "Expected #{is} should #{op_name} #{should_be}, but it does not"
	success = false
	new_exception = Exception.new(message)
	begin
		success = op_lookup.(op).(is, should_be)
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

did_test_pass = ->(test_to_run) {
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

did_test_fail = ->(test_to_run) { !did_test_pass.(test_to_run)}

failure_report = ->(test_number, failures) { (puts("#{failures}") || puts("#{failures.length} Failures out of #{test_number} Tests:") || map.(->(failure) { puts failure.first }).(failures)) if failures.length > 0 }

run_tests = ->(tests_to_run) { failure_report.(tests_to_run.length) * filter.(did_test_fail) * ->(tests) { puts "Running #{tests.length} Tests"; puts(SEPARATOR); tests} <= tests_to_run }

run_tests.([["test1", -> { check.("equal", false, false); check.("equal", true, true); check.("gte", 7, 5)}], ["test2", -> { check.("equal", true, false) }]])
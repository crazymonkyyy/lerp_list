//struct foo{
//	void opOpAssign(string s:"~")(int i, char c){
//	}
//}
//void main(){
//	foo bar;
//	bar~=(1,'a');
//}

unittest{
//int[10] foo=[1,2,3,4,5,6,7,8,9,10];
//foreach(i;0..15){
//	import basic;
//	foo[i>=$? $-1 : i].writeln;
//}
}
struct myrange{
	int until;
	int i=0;
	auto front(){return i;}
	void popFront(){i++;}
	bool empty(){return i>until;}
}
auto stateful(T)(ref T range){
	struct statefulrange(S){
		S* r; alias r this;
		//auto opDispatch(string s,Arg...)(Arg arg){
		//	mixin("return r."~s~"(arg);");}
		auto front(){
			return r.front;}
		void popFront(){
			r.popFront;}
		bool empty(){
			return r.empty;}
	}
	return statefulrange!T(&range);
}
import basic;
unittest{
	auto bar=myrange(10);
	auto foo=stateful(bar);
	foreach(j,i;zip(foo,iota(20,100))){
		i.writeln; j.writeln;
		if(i%2){foo.until++;}
	}
}
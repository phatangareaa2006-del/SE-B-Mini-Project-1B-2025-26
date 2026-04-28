import { useEffect } from "react";
import { useNavigate, useSearchParams } from "react-router-dom";
import { Briefcase, Sparkles, Users, Building2 } from "lucide-react";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Card, CardContent } from "@/components/ui/card";
import LoginForm from "@/components/auth/LoginForm";
import SignupForm from "@/components/auth/SignupForm";
import { useAuth } from "@/contexts/AuthContext";

const AuthPage = () => {
  const { user } = useAuth();
  const navigate = useNavigate();
  const [searchParams, setSearchParams] = useSearchParams();
  const activeTab = searchParams.get("tab") || "login";

  useEffect(() => {
    if (user) {
      navigate("/", { replace: true });
    }
  }, [user, navigate]);

  const handleTabChange = (value: string) => {
    setSearchParams({ tab: value });
  };

  const features = [
    {
      icon: Users,
      title: "Connect with Recruiters",
      description: "Direct access to top companies hiring fresh talent",
    },
    {
      icon: Briefcase,
      title: "Smart Job Matching",
      description: "AI-powered recommendations based on your skills",
    },
    {
      icon: Sparkles,
      title: "Resume Parser",
      description: "Auto-extract skills from your resume with AI",
    },
    {
      icon: Building2,
      title: "Multi-College Network",
      description: "Connect with students and alumni across institutions",
    },
  ];

  return (
    <div className="min-h-screen flex">
      {/* Left Panel - Branding */}
      <div className="hidden lg:flex lg:w-1/2 xl:w-3/5 gradient-hero p-8 lg:p-12 flex-col justify-between text-white">
        <div>
          <div className="flex items-center gap-3">
            <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-white/20 backdrop-blur">
              <Briefcase className="h-6 w-6" />
            </div>
            <span className="text-2xl font-bold font-display">PlacementHub</span>
          </div>
        </div>

        <div className="space-y-8">
          <div className="space-y-4">
            <h1 className="text-4xl xl:text-5xl font-bold font-display leading-tight">
              Your Gateway to
              <br />
              <span className="text-white/90">Career Success</span>
            </h1>
            <p className="text-lg text-white/80 max-w-md">
              Connect with top companies, discover opportunities, and land your dream job through our intelligent placement platform.
            </p>
          </div>

          <div className="grid gap-4 sm:grid-cols-2">
            {features.map((feature, index) => {
              const Icon = feature.icon;
              return (
                <div
                  key={index}
                  className="flex items-start gap-4 rounded-xl bg-white/10 backdrop-blur p-4 transition-all hover:bg-white/20"
                >
                  <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg bg-white/20">
                    <Icon className="h-5 w-5" />
                  </div>
                  <div>
                    <h3 className="font-semibold">{feature.title}</h3>
                    <p className="text-sm text-white/70">{feature.description}</p>
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        <div className="text-sm text-white/60">
          Trusted by 500+ colleges and 1000+ companies across India
        </div>
      </div>

      {/* Right Panel - Auth Forms */}
      <div className="flex w-full lg:w-1/2 xl:w-2/5 items-center justify-center p-4 sm:p-8 bg-background">
        <Card className="w-full max-w-md border-0 shadow-none sm:border sm:shadow-lg">
          <CardContent className="p-6 sm:p-8">
            {/* Mobile Logo */}
            <div className="lg:hidden flex items-center justify-center gap-2 mb-8">
              <div className="flex h-10 w-10 items-center justify-center rounded-lg gradient-bg">
                <Briefcase className="h-5 w-5 text-primary-foreground" />
              </div>
              <span className="text-xl font-bold font-display">PlacementHub</span>
            </div>

            <Tabs
              value={activeTab}
              onValueChange={handleTabChange}
              className="w-full"
            >
              <TabsList className="grid w-full grid-cols-2 mb-6">
                <TabsTrigger value="login">Sign In</TabsTrigger>
                <TabsTrigger value="signup">Sign Up</TabsTrigger>
              </TabsList>
              <TabsContent value="login" className="mt-0">
                <LoginForm />
              </TabsContent>
              <TabsContent value="signup" className="mt-0">
                <SignupForm />
              </TabsContent>
            </Tabs>
          </CardContent>
        </Card>
      </div>
    </div>
  );
};

export default AuthPage;

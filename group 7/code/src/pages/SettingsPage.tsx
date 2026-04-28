import { useState } from "react";
import { Link } from "react-router-dom";
import { Settings, User, Bell, Lock, Palette, Shield, ChevronLeft, Moon, Sun, Monitor, Trash2, LogOut } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import { Separator } from "@/components/ui/separator";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import Navbar from "@/components/layout/Navbar";
import Sidebar from "@/components/home/Sidebar";
import { useAuth } from "@/contexts/AuthContext";
import { useTheme } from "@/hooks/useTheme";
import { cn } from "@/lib/utils";
import { toast } from "sonner";

const SettingsPage = () => {
  const { user, signOut, updatePassword } = useAuth();
  const { theme, setTheme } = useTheme();
  const [sidebarCollapsed] = useState(false);
  const [notifMessages, setNotifMessages] = useState(true);
  const [notifConnections, setNotifConnections] = useState(true);
  const [notifApplications, setNotifApplications] = useState(true);
  const [notifDesktop, setNotifDesktop] = useState(false);
  const [profileVisibility, setProfileVisibility] = useState("public");
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [changingPassword, setChangingPassword] = useState(false);

  const handlePasswordChange = async () => {
    if (newPassword.length < 6) {
      toast.error("Password must be at least 6 characters");
      return;
    }
    if (newPassword !== confirmPassword) {
      toast.error("Passwords do not match");
      return;
    }
    setChangingPassword(true);
    const { error } = await updatePassword(newPassword);
    if (error) {
      toast.error(error.message);
    } else {
      toast.success("Password updated successfully!");
      setNewPassword("");
      setConfirmPassword("");
    }
    setChangingPassword(false);
  };

  const requestDesktopNotifications = async () => {
    if (!("Notification" in window)) {
      toast.error("Your browser doesn't support notifications");
      return;
    }
    const permission = await Notification.requestPermission();
    if (permission === "granted") {
      setNotifDesktop(true);
      toast.success("Desktop notifications enabled!");
      new Notification("PlacementHub", { body: "Notifications are now enabled!" });
    } else {
      toast.error("Notification permission denied");
    }
  };

  const handleDeleteSearchHistory = async () => {
    if (!user) return;
    const { error } = await supabase.from("search_history").delete().eq("user_id", user.id);
    if (error) {
      toast.error("Failed to clear search history");
    } else {
      toast.success("Search history cleared");
    }
  };

  return (
    <div className="min-h-screen bg-background">
      <Navbar />
      <Sidebar isCollapsed={sidebarCollapsed} />

      <main className={cn("transition-all duration-300 pt-16", "lg:ml-64", sidebarCollapsed && "lg:ml-16")}>
        <div className="border-b bg-card px-4 lg:px-6 py-6">
          <div className="max-w-3xl mx-auto">
            <Link to="/" className="inline-flex items-center gap-2 text-sm text-muted-foreground hover:text-foreground mb-4">
              <ChevronLeft className="h-4 w-4" /> Back to Home
            </Link>
            <div className="flex items-center gap-3">
              <div className="h-10 w-10 rounded-xl bg-primary/10 flex items-center justify-center">
                <Settings className="h-5 w-5 text-primary" />
              </div>
              <div>
                <h1 className="text-2xl lg:text-3xl font-bold">Settings</h1>
                <p className="text-muted-foreground">Manage your account preferences</p>
              </div>
            </div>
          </div>
        </div>

        <div className="px-4 lg:px-6 py-8 max-w-3xl mx-auto">
          <Tabs defaultValue="account" className="space-y-6">
            <TabsList className="grid w-full grid-cols-4 h-auto">
              <TabsTrigger value="account" className="text-xs sm:text-sm">Account</TabsTrigger>
              <TabsTrigger value="notifications" className="text-xs sm:text-sm">Notifications</TabsTrigger>
              <TabsTrigger value="appearance" className="text-xs sm:text-sm">Appearance</TabsTrigger>
              <TabsTrigger value="privacy" className="text-xs sm:text-sm">Privacy</TabsTrigger>
            </TabsList>

            {/* Account */}
            <TabsContent value="account" className="space-y-6">
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2"><User className="h-5 w-5" /> Account Info</CardTitle>
                  <CardDescription>Your account details</CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div>
                    <Label>Email</Label>
                    <Input value={user?.email || ""} disabled className="mt-1" />
                  </div>
                  <div>
                    <Label>User ID</Label>
                    <Input value={user?.id?.slice(0, 8) + "..." || ""} disabled className="mt-1 font-mono text-xs" />
                  </div>
                  <div>
                    <Label>Joined</Label>
                    <Input value={user?.created_at ? new Date(user.created_at).toLocaleDateString() : ""} disabled className="mt-1" />
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2"><Lock className="h-5 w-5" /> Change Password</CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div>
                    <Label>New Password</Label>
                    <Input type="password" value={newPassword} onChange={(e) => setNewPassword(e.target.value)} className="mt-1" placeholder="Enter new password" />
                  </div>
                  <div>
                    <Label>Confirm Password</Label>
                    <Input type="password" value={confirmPassword} onChange={(e) => setConfirmPassword(e.target.value)} className="mt-1" placeholder="Confirm new password" />
                  </div>
                  <Button onClick={handlePasswordChange} disabled={changingPassword}>
                    {changingPassword ? "Updating..." : "Update Password"}
                  </Button>
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2"><Trash2 className="h-5 w-5" /> Data Management</CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="font-medium text-sm">Clear Search History</p>
                      <p className="text-xs text-muted-foreground">Remove all saved search queries</p>
                    </div>
                    <Button variant="outline" size="sm" onClick={handleDeleteSearchHistory}>Clear</Button>
                  </div>
                  <Separator />
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="font-medium text-sm text-destructive">Sign Out</p>
                      <p className="text-xs text-muted-foreground">Sign out of your account</p>
                    </div>
                    <Button variant="destructive" size="sm" onClick={signOut} className="gap-1">
                      <LogOut className="h-4 w-4" /> Sign Out
                    </Button>
                  </div>
                </CardContent>
              </Card>
            </TabsContent>

            {/* Notifications */}
            <TabsContent value="notifications" className="space-y-6">
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2"><Bell className="h-5 w-5" /> Notification Preferences</CardTitle>
                </CardHeader>
                <CardContent className="space-y-6">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="font-medium text-sm">Messages</p>
                      <p className="text-xs text-muted-foreground">Get notified when someone messages you</p>
                    </div>
                    <Switch checked={notifMessages} onCheckedChange={setNotifMessages} />
                  </div>
                  <Separator />
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="font-medium text-sm">Connection Requests</p>
                      <p className="text-xs text-muted-foreground">Get notified for new connection requests</p>
                    </div>
                    <Switch checked={notifConnections} onCheckedChange={setNotifConnections} />
                  </div>
                  <Separator />
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="font-medium text-sm">Application Updates</p>
                      <p className="text-xs text-muted-foreground">Status changes on your job applications</p>
                    </div>
                    <Switch checked={notifApplications} onCheckedChange={setNotifApplications} />
                  </div>
                  <Separator />
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="font-medium text-sm">Desktop Notifications</p>
                      <p className="text-xs text-muted-foreground">Receive push notifications on your desktop</p>
                    </div>
                    <Button variant="outline" size="sm" onClick={requestDesktopNotifications}>
                      {notifDesktop ? "Enabled ✓" : "Enable"}
                    </Button>
                  </div>
                </CardContent>
              </Card>
            </TabsContent>

            {/* Appearance */}
            <TabsContent value="appearance" className="space-y-6">
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2"><Palette className="h-5 w-5" /> Theme</CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="grid grid-cols-3 gap-4">
                    {[
                      { value: "light", icon: Sun, label: "Light" },
                      { value: "dark", icon: Moon, label: "Dark" },
                      { value: "system", icon: Monitor, label: "System" },
                    ].map(({ value, icon: Icon, label }) => (
                      <button
                        key={value}
                        onClick={() => setTheme(value as any)}
                        className={cn(
                          "flex flex-col items-center gap-2 p-4 rounded-xl border transition-all",
                          theme === value ? "border-primary bg-primary/5" : "hover:bg-muted"
                        )}
                      >
                        <Icon className={cn("h-6 w-6", theme === value && "text-primary")} />
                        <span className="text-sm font-medium">{label}</span>
                      </button>
                    ))}
                  </div>
                </CardContent>
              </Card>
            </TabsContent>

            {/* Privacy */}
            <TabsContent value="privacy" className="space-y-6">
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2"><Shield className="h-5 w-5" /> Privacy Settings</CardTitle>
                </CardHeader>
                <CardContent className="space-y-6">
                  <div>
                    <Label>Profile Visibility</Label>
                    <Select value={profileVisibility} onValueChange={setProfileVisibility}>
                      <SelectTrigger className="mt-1">
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="public">Public - Anyone can view</SelectItem>
                        <SelectItem value="connections">Connections Only</SelectItem>
                        <SelectItem value="private">Private - Only me</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                  <Separator />
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="font-medium text-sm">Show Online Status</p>
                      <p className="text-xs text-muted-foreground">Let others see when you're active</p>
                    </div>
                    <Switch defaultChecked />
                  </div>
                  <Separator />
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="font-medium text-sm">Allow Profile Discovery</p>
                      <p className="text-xs text-muted-foreground">Appear in search results and suggestions</p>
                    </div>
                    <Switch defaultChecked />
                  </div>
                </CardContent>
              </Card>
            </TabsContent>
          </Tabs>
        </div>
      </main>
    </div>
  );
};

export default SettingsPage;

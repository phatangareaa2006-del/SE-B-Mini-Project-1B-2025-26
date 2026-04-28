import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { Users, Search, UserPlus, Check, X, ChevronLeft, MessageSquare, Mail } from "lucide-react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Card, CardContent } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import Navbar from "@/components/layout/Navbar";
import MobileNav from "@/components/layout/MobileNav";
import Sidebar from "@/components/home/Sidebar";
import { useAuth } from "@/contexts/AuthContext";
import { cn } from "@/lib/utils";
import { Skeleton } from "@/components/ui/skeleton";
import { toast } from "sonner";

const NetworkPage = () => {
  const { user } = useAuth();
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const [sidebarCollapsed] = useState(false);
  const [searchQuery, setSearchQuery] = useState("");
  const [activeTab, setActiveTab] = useState("discover");

  // Fetch all profiles (for discover) - search by name or email
  const { data: profiles, isLoading: loadingProfiles } = useQuery({
    queryKey: ["profiles", searchQuery],
    queryFn: async () => {
      let query = supabase
        .from("profiles")
        .select("*")
        .neq("user_id", user?.id || "")
        .limit(50);

      if (searchQuery) {
        query = query.or(`full_name.ilike.%${searchQuery}%,headline.ilike.%${searchQuery}%,email.ilike.%${searchQuery}%`);
      }

      const { data, error } = await query;
      if (error) throw error;
      return data;
    },
    enabled: !!user,
  });

  // Fetch connections
  const { data: connections, isLoading: loadingConnections } = useQuery({
    queryKey: ["connections", user?.id],
    queryFn: async () => {
      if (!user) return { pending: [], accepted: [] };
      const { data, error } = await supabase
        .from("connections")
        .select("*")
        .or(`requester_id.eq.${user.id},addressee_id.eq.${user.id}`);
      if (error) throw error;

      const pending = data?.filter((c) => c.status === "pending" && c.addressee_id === user.id) || [];
      const accepted = data?.filter((c) => c.status === "accepted") || [];
      const allConnectionIds = [...accepted, ...data?.filter((c) => c.status === "pending") || []].map((c) =>
        c.requester_id === user.id ? c.addressee_id : c.requester_id
      );

      return { pending, accepted, allConnectionIds };
    },
    enabled: !!user,
  });

  // Fetch profiles for connected users
  const connectedUserIds = connections?.accepted?.map((c) =>
    c.requester_id === user?.id ? c.addressee_id : c.requester_id
  ) || [];

  const { data: connectedProfiles } = useQuery({
    queryKey: ["connected-profiles", connectedUserIds],
    queryFn: async () => {
      if (connectedUserIds.length === 0) return [];
      const { data, error } = await supabase
        .from("profiles")
        .select("*")
        .in("user_id", connectedUserIds);
      if (error) throw error;
      return data;
    },
    enabled: connectedUserIds.length > 0,
  });

  const pendingUserIds = connections?.pending?.map((c) => c.requester_id) || [];
  const { data: pendingProfiles } = useQuery({
    queryKey: ["pending-profiles", pendingUserIds],
    queryFn: async () => {
      if (pendingUserIds.length === 0) return [];
      const { data, error } = await supabase
        .from("profiles")
        .select("*")
        .in("user_id", pendingUserIds);
      if (error) throw error;
      return data;
    },
    enabled: pendingUserIds.length > 0,
  });

  const sendRequest = useMutation({
    mutationFn: async (addresseeId: string) => {
      const { error } = await supabase.from("connections").insert({
        requester_id: user!.id,
        addressee_id: addresseeId,
        status: "pending",
      });
      if (error) throw error;

      // Send notification
      await supabase.from("notifications").insert({
        user_id: addresseeId,
        type: "connection_request",
        title: "New Connection Request",
        message: `Someone wants to connect with you`,
      });
    },
    onSuccess: () => {
      toast.success("Connection request sent!");
      queryClient.invalidateQueries({ queryKey: ["connections"] });
    },
    onError: () => toast.error("Failed to send request"),
  });

  const acceptConnection = useMutation({
    mutationFn: async (connectionId: string) => {
      const { error } = await supabase.from("connections").update({ status: "accepted" }).eq("id", connectionId);
      if (error) throw error;
    },
    onSuccess: () => {
      toast.success("Connection accepted!");
      queryClient.invalidateQueries({ queryKey: ["connections"] });
    },
  });

  const rejectConnection = useMutation({
    mutationFn: async (connectionId: string) => {
      const { error } = await supabase.from("connections").update({ status: "rejected" }).eq("id", connectionId);
      if (error) throw error;
    },
    onSuccess: () => {
      toast.success("Connection rejected");
      queryClient.invalidateQueries({ queryKey: ["connections"] });
    },
  });

  const startChat = async (partnerId: string) => {
    navigate("/messages");
  };

  const getInitials = (name?: string | null) => {
    if (!name) return "U";
    return name.split(" ").map((n) => n[0]).join("").toUpperCase().slice(0, 2);
  };

  const isAlreadyConnected = (userId: string) => {
    return (connections as any)?.allConnectionIds?.includes(userId);
  };

  return (
    <div className="min-h-screen bg-background">
      <Navbar />
      <MobileNav />
      <Sidebar isCollapsed={sidebarCollapsed} />

      <main className={cn("transition-all duration-300 pt-16 pb-16 md:pb-0", "md:ml-64", sidebarCollapsed && "md:ml-16")}>
        <div className="border-b bg-card px-4 lg:px-6 py-6">
          <div className="max-w-4xl mx-auto">
            <Link to="/" className="inline-flex items-center gap-2 text-sm text-muted-foreground hover:text-foreground mb-4">
              <ChevronLeft className="h-4 w-4" /> Back to Home
            </Link>
            <div className="flex items-center gap-3">
              <div className="h-10 w-10 rounded-xl bg-primary/10 flex items-center justify-center">
                <Users className="h-5 w-5 text-primary" />
              </div>
              <div>
                <h1 className="text-2xl lg:text-3xl font-bold">My Network</h1>
                <p className="text-muted-foreground">{connections?.accepted?.length || 0} connections</p>
              </div>
            </div>
          </div>
        </div>

        <div className="px-4 lg:px-6 py-8 max-w-4xl mx-auto">
          <Tabs value={activeTab} onValueChange={setActiveTab}>
            <TabsList className="mb-6">
              <TabsTrigger value="discover">Discover</TabsTrigger>
              <TabsTrigger value="pending" className="relative">
                Pending
                {connections?.pending && connections.pending.length > 0 && (
                  <span className="ml-2 h-5 w-5 rounded-full bg-primary text-primary-foreground text-xs flex items-center justify-center">
                    {connections.pending.length}
                  </span>
                )}
              </TabsTrigger>
              <TabsTrigger value="connections">Connections</TabsTrigger>
            </TabsList>

            <TabsContent value="discover">
              <div className="mb-6">
                <div className="relative">
                  <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                  <Input
                    placeholder="Search by name or email..."
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    className="pl-9"
                  />
                </div>
              </div>

              {loadingProfiles ? (
                <div className="grid gap-4">
                  {[1, 2, 3, 4].map((i) => (<Skeleton key={i} className="h-24 rounded-xl" />))}
                </div>
              ) : profiles && profiles.length > 0 ? (
                <div className="grid gap-4">
                  {profiles.map((profile) => (
                    <Card key={profile.id}>
                      <CardContent className="p-4">
                        <div className="flex items-center gap-4">
                          <Avatar className="h-14 w-14">
                            <AvatarImage src={profile.avatar_url || undefined} />
                            <AvatarFallback className="bg-primary/10 text-primary">{getInitials(profile.full_name)}</AvatarFallback>
                          </Avatar>
                          <div className="flex-1 min-w-0">
                            <h3 className="font-semibold truncate">{profile.full_name || "Unknown User"}</h3>
                            <p className="text-sm text-muted-foreground truncate">{profile.headline || "No headline"}</p>
                            <p className="text-xs text-muted-foreground flex items-center gap-1">
                              <Mail className="h-3 w-3" /> {profile.email}
                            </p>
                          </div>
                          <Button
                            size="sm"
                            onClick={() => sendRequest.mutate(profile.user_id)}
                            disabled={sendRequest.isPending || isAlreadyConnected(profile.user_id)}
                          >
                            {isAlreadyConnected(profile.user_id) ? (
                              "Connected"
                            ) : (
                              <><UserPlus className="h-4 w-4 mr-1" /> Connect</>
                            )}
                          </Button>
                        </div>
                      </CardContent>
                    </Card>
                  ))}
                </div>
              ) : (
                <div className="text-center py-12">
                  <Users className="h-12 w-12 mx-auto text-muted-foreground mb-4" />
                  <p className="text-muted-foreground">No users found</p>
                </div>
              )}
            </TabsContent>

            <TabsContent value="pending">
              {loadingConnections ? (
                <div className="grid gap-4">
                  {[1, 2].map((i) => (<Skeleton key={i} className="h-24 rounded-xl" />))}
                </div>
              ) : connections?.pending && connections.pending.length > 0 ? (
                <div className="grid gap-4">
                  {connections.pending.map((connection) => {
                    const profile = pendingProfiles?.find((p) => p.user_id === connection.requester_id);
                    return (
                      <Card key={connection.id}>
                        <CardContent className="p-4">
                          <div className="flex items-center gap-4">
                            <Avatar className="h-14 w-14">
                              <AvatarImage src={profile?.avatar_url || undefined} />
                              <AvatarFallback className="bg-primary/10 text-primary">{getInitials(profile?.full_name)}</AvatarFallback>
                            </Avatar>
                            <div className="flex-1">
                              <h3 className="font-semibold">{profile?.full_name || "User"}</h3>
                              <p className="text-sm text-muted-foreground">{profile?.headline || "Wants to connect"}</p>
                            </div>
                            <div className="flex gap-2">
                              <Button size="sm" onClick={() => acceptConnection.mutate(connection.id)}>
                                <Check className="h-4 w-4 mr-1" /> Accept
                              </Button>
                              <Button size="sm" variant="outline" onClick={() => rejectConnection.mutate(connection.id)}>
                                <X className="h-4 w-4" />
                              </Button>
                            </div>
                          </div>
                        </CardContent>
                      </Card>
                    );
                  })}
                </div>
              ) : (
                <div className="text-center py-12">
                  <UserPlus className="h-12 w-12 mx-auto text-muted-foreground mb-4" />
                  <p className="text-muted-foreground">No pending requests</p>
                </div>
              )}
            </TabsContent>

            <TabsContent value="connections">
              {connectedProfiles && connectedProfiles.length > 0 ? (
                <div className="grid gap-4">
                  {connectedProfiles.map((profile) => (
                    <Card key={profile.id}>
                      <CardContent className="p-4">
                        <div className="flex items-center gap-4">
                          <Avatar className="h-14 w-14">
                            <AvatarImage src={profile.avatar_url || undefined} />
                            <AvatarFallback className="bg-primary/10 text-primary">{getInitials(profile.full_name)}</AvatarFallback>
                          </Avatar>
                          <div className="flex-1">
                            <h3 className="font-semibold">{profile.full_name || "User"}</h3>
                            <p className="text-sm text-muted-foreground">{profile.headline || "PlacementHub User"}</p>
                          </div>
                          <Button size="sm" variant="outline" onClick={() => startChat(profile.user_id)} className="gap-1">
                            <MessageSquare className="h-4 w-4" /> Message
                          </Button>
                        </div>
                      </CardContent>
                    </Card>
                  ))}
                </div>
              ) : (
                <div className="text-center py-12">
                  <Users className="h-12 w-12 mx-auto text-muted-foreground mb-4" />
                  <p className="text-muted-foreground">No connections yet</p>
                  <Button variant="outline" className="mt-4" onClick={() => setActiveTab("discover")}>Discover People</Button>
                </div>
              )}
            </TabsContent>
          </Tabs>
        </div>
      </main>
    </div>
  );
};

export default NetworkPage;

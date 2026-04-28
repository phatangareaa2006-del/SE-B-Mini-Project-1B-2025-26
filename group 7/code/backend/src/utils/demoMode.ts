// Shared demo mode storage
export const demoProfiles = new Map<string, any>();

export const setDemoProfile = (userId: string, profile: any) => {
  demoProfiles.set(userId, profile);
};

export const getDemoProfile = (userId: string) => {
  return demoProfiles.get(userId);
};

export const updateDemoProfile = (userId: string, updates: any) => {
  const profile = demoProfiles.get(userId);
  if (profile) {
    Object.assign(profile, updates, { updated_at: new Date().toISOString() });
    demoProfiles.set(userId, profile);
  }
  return profile;
};

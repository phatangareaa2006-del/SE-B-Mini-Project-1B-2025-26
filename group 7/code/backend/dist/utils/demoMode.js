// Shared demo mode storage
export const demoProfiles = new Map();
export const setDemoProfile = (userId, profile) => {
    demoProfiles.set(userId, profile);
};
export const getDemoProfile = (userId) => {
    return demoProfiles.get(userId);
};
export const updateDemoProfile = (userId, updates) => {
    const profile = demoProfiles.get(userId);
    if (profile) {
        Object.assign(profile, updates, { updated_at: new Date().toISOString() });
        demoProfiles.set(userId, profile);
    }
    return profile;
};
//# sourceMappingURL=demoMode.js.map
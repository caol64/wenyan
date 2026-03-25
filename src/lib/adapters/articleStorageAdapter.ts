import type { ArticleStorageAdapter, Article } from "@wenyan-md/ui";
import { loadArticles, saveArticle } from "../action";

export const articleStorageAdapter: ArticleStorageAdapter = {
    async load(): Promise<Article[]> {
        const content = await loadArticles();
        return content ? [{
            id: "last-article",
            title: "Last Article",
            content,
            created: Date.now(),
        }] : [];
    },
    async save(article: Article): Promise<void> {
        await saveArticle(article.content);
    },
    async remove(id: string): Promise<void> {

    },
};
